import cake/adapter/sqlite
import cake/select as s
import cake/where as w
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import sqlight

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

fn fetch_user_by_username(username: String) {
  s.new()
  |> s.selects([s.col("username"), s.col("password")])
  |> s.from_table("users")
  |> s.where(w.col("username") |> w.eq(w.string(username)))
  |> s.limit(1)
  |> s.to_query
}

type User {
  User(username: String, password: String)
}

fn user(row) {
  row
  |> dynamic.from
  |> dynamic.decode2(
    User,
    dynamic.element(0, dynamic.string),
    dynamic.element(1, dynamic.string),
  )
}

pub fn login(
  db: sqlight.Connection,
  authenticator: Authenticator,
) -> Result(Tokens, AuthError) {
  case authenticator {
    UsernamePasswordAuthenticator(username: username, password: password) -> {
      let db_res =
        username
        |> fetch_user_by_username()
        |> sqlite.run_read_query(decode.dynamic, db)

      let res =
        case db_res {
          Ok(val) -> {
            list.map(val, fn(x) {
              user(x) |> result.map_error(fn(_) { AuthError("failed") })
            })
            |> list.first
            |> result.map_error(fn(_) { AuthError("failed") })
          }
          Error(_) -> Error(AuthError("failed"))
        }
        |> result.flatten

      case res {
        Ok(val) -> Ok(Tokens("access_token", "refresh_token"))
        Error(err) -> Error(AuthError("Invalid creds"))
      }
    }
  }
}
