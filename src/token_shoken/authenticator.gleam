import gleam/bool
import gleam/json
import gleam/result
import token_shoken/user as user_repo

pub type Authenticator {
  UsernamePasswordAuthenticator(username: String, password: String)
}

pub type Tokens {
  Tokens(access_token: String, refresh_token: String)
}

pub type AuthError {
  UserNotPresentError(Nil)
  InvalidCredentialsError
  UserNotActiveError
}

pub fn to_json(resp: Tokens) -> json.Json {
  [
    #("access_token", json.string(resp.access_token)),
    #("refresh_token", json.string(resp.refresh_token)),
  ]
  |> json.object
}

pub fn login(authenticator: Authenticator) -> Result(Tokens, AuthError) {
  case authenticator {
    UsernamePasswordAuthenticator(username: username, password: password) -> {
      login_with_password(username, password)
    }
  }
}

fn login_with_password(
  username: String,
  password: String,
) -> Result(Tokens, AuthError) {
  use user <- result.try(
    user_repo.get_user(username) |> result.map_error(UserNotPresentError),
  )
  use <- bool.guard(user.password != password, Error(InvalidCredentialsError))
  use <- bool.guard(!user.is_active, Error(UserNotActiveError))

  Ok(Tokens("access_token", "refresh_token"))
}
