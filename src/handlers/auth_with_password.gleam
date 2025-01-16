import authenticator
import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/result
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

type BadRequestError {
  DecodeError(message: String)
  InvalidCredentialsError(message: String)
}

pub fn handler(req: wisp.Request) -> wisp.Response {
  use <- wisp.require_method(req, http.Post)
  use json <- wisp.require_json(req)

  let auth_result =
    json
    |> decode.run(decode_request())
    |> result.map_error(fn(_x) { DecodeError(message: "Decoding failed") })
    |> result.try(fn(x) {
      authenticator.login(authenticator.UsernamePasswordAuthenticator(
        x.username,
        x.password,
      ))
      |> result.map_error(fn(x) { InvalidCredentialsError(message: x.message) })
    })

  case auth_result {
    Ok(resp) -> {
      resp
      |> authenticator.to_json
      |> json.to_string_tree
      |> wisp.json_response(200)
    }
    Error(_) -> wisp.bad_request()
  }
}
