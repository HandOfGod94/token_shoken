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

type HandlerError {
  BadRequestError(message: String)
  InvalidCredentialError(message: String)
}

fn decode_request(
  json: dynamic.Dynamic,
) -> Result(AuthWithPassword, HandlerError) {
  let decoder = {
    use username <- decode.field("username", decode.string)
    use password <- decode.field("password", decode.string)
    decode.success(AuthWithPassword(username:, password:))
  }

  json
  |> decode.run(decoder)
  |> result.map_error(fn(_) { BadRequestError(message: "Invalid request") })
}

pub fn handler(req: wisp.Request) -> wisp.Response {
  use <- wisp.require_method(req, http.Post)
  use json <- wisp.require_json(req)

  let login_result =
    json
    |> decode_request()
    |> result.map(fn(x) {
      authenticator.login(authenticator.UsernamePasswordAuthenticator(
        username: x.username,
        password: x.password,
      ))
      |> result.map_error(fn(x) { InvalidCredentialError(x.message) })
    })
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
