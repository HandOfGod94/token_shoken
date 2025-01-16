import gleam/json

pub type Authenticator {
  UsernamePasswordAuthenticator(username: String, password: String)
}

pub type Tokens {
  Tokens(access_token: String, refresh_token: String)
}

pub type AuthError {
  AuthError(message: String)
}

pub type AuthSuccessResponse {
  AuthSuccessResponse(access_token: String, refresh_token: String)
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
    UsernamePasswordAuthenticator(username: username, password: password) ->
      Ok(Tokens(username, password))
  }
}
