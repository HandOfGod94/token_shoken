import authenticator
import gleam/dynamic
import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/result
import wisp

type AuthWithPassword {
  AuthWithPassword(username: String, password: String)
  // TODO: make username vs email distinction
}

fn decode_request(
  json: dynamic.Dynamic,
  next: fn(Result(AuthWithPassword, List(decode.DecodeError))) -> wisp.Response,
) -> wisp.Response {
  let decoder = {
    use username <- decode.field("username", decode.string)
    use password <- decode.field("password", decode.string)
    decode.success(AuthWithPassword(username:, password:))
  }

  next(decode.run(json, decoder))
}

pub fn handler(req: wisp.Request) -> wisp.Response {
  use <- wisp.require_method(req, http.Post)
  use json <- wisp.require_json(req)
  use body <- decode_request(json)

  let login_result =
    body
    |> result.map(fn(x) {
      authenticator.login(authenticator.UsernamePasswordAuthenticator(
        username: x.username,
        password: x.password,
      ))
    })
    |> result.map_error(fn(_) { authenticator.AuthError("Invalid credentials") })
    |> result.flatten()

  case login_result {
    Ok(tokens) ->
      tokens
      |> authenticator.to_json
      |> json.to_string_tree
      |> wisp.json_response(200)
    Error(err) ->
      [#("message", json.string(err.message))]
      |> json.object
      |> json.to_string_tree
      |> wisp.json_response(401)
  }
}
