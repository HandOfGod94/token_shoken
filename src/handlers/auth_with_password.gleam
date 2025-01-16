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

fn login_user(
  creds: authenticator.Authenticator,
  next: fn(Result(authenticator.Tokens, authenticator.AuthError)) ->
    wisp.Response,
) -> wisp.Response {
  let res = authenticator.login(creds)
  next(res)
}

pub fn handler(req: wisp.Request) -> wisp.Response {
  use <- wisp.require_method(req, http.Post)
  use json <- wisp.require_json(req)
  use body <- decode_request(json)
  use res <- login_user(authenticator.UsernamePasswordAuthenticator(
    result.unwrap(body, AuthWithPassword("", "")).username,
    result.unwrap(body, AuthWithPassword("", "")).password,
  ))

  case res {
    Ok(val) ->
      val
      |> authenticator.to_json
      |> json.to_string_tree
      |> wisp.json_response(200)
    Error(_err) -> wisp.bad_request()
  }
}
