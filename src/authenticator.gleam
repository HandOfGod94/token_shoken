import gleam/json

pub type Authenticator {
  UsernamePasswordAuthenticator(username: String, password: String)
}

pub type AuthSuccessResponse {
  AuthSuccessResponse(access_token: String, refresh_token: String)
}

pub fn to_json(resp: AuthSuccessResponse) -> json.Json {
  [
    #("access_token", json.string(resp.access_token)),
    #("refresh_token", json.string(resp.refresh_token)),
  ]
  |> json.object
}

pub fn login(authenticator: Authenticator) -> AuthSuccessResponse {
  case authenticator {
    UsernamePasswordAuthenticator(username: username, password: password) ->
      AuthSuccessResponse(username, password)
  }
}
