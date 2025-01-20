import gleam/bool
import gleam/dynamic
import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/result
import token_shoken/user
import wisp.{type Request, type Response}

type RegisterUserRequest {
  RegisterUserRequest(
    username: String,
    password: String,
    password_confirm: String,
    email: String,
  )
}

type RegisterUserRequestError {
  BadRequestError(List(decode.DecodeError))
  PasswordConfirmMatchError
  UnableToCreateUserError(Nil)
}

fn decode_request(
  json: dynamic.Dynamic,
) -> Result(RegisterUserRequest, List(decode.DecodeError)) {
  let decoder = {
    use username <- decode.field("username", decode.string)
    use password <- decode.field("password", decode.string)
    use password_confirm <- decode.field("password_confirm", decode.string)
    use email <- decode.field("email", decode.string)
    decode.success(RegisterUserRequest(
      username:,
      password:,
      password_confirm:,
      email:,
    ))
  }

  json
  |> decode.run(decoder)
}

pub fn handler(req: Request) -> Response {
  use json <- wisp.require_json(req)

  let handle = {
    use params <- result.try(
      json |> decode_request |> result.map_error(BadRequestError),
    )
    use <- bool.guard(
      params.password != params.password_confirm,
      // TODO: do secure match
      Error(PasswordConfirmMatchError),
    )
    let RegisterUserRequest(username, password, _, email) = params
    user.create_user(username:, password:, email:)
    |> result.map_error(UnableToCreateUserError)
  }

  case handle {
    Ok(id) ->
      [#("id", json.int(id))]
      |> json.object
      |> json.to_string_tree
      |> wisp.json_response(201)
    Error(err) -> {
      io.debug(err)
      wisp.bad_request()
    }
  }
}
