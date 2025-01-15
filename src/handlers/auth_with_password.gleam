import authenticator
import gleam/dynamic/decode
import gleam/http
import gleam/json
import wisp

type AuthWithPassword {
  AuthWithPassword(username: String, password: String)
  // TODO: make username vs email distinction
}

fn decode_request() -> decode.Decoder(AuthWithPassword) {
  use username <- decode.field("username", decode.string)
  use password <- decode.field("password", decode.string)
  decode.success(AuthWithPassword(username:, password:))
}

pub fn handler(req: wisp.Request) -> wisp.Response {
  use <- wisp.require_method(req, http.Post)
  use json <- wisp.require_json(req)

  let result = decode.run(json, decode_request())
  case result {
    Ok(auther) ->
      authenticator.login(authenticator.UsernamePasswordAuthenticator(
        auther.username,
        auther.password,
      ))
      |> authenticator.to_json
      |> json.to_string_tree
      |> wisp.json_response(200)
    Error(_) -> wisp.bad_request()
  }
}
