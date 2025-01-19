import dot_env as dot
import dot_env/env
import gleam/erlang/process
import gleam/http
import mist
import token_shoken/app
import token_shoken/handlers/auth_with_password
import token_shoken/handlers/health_check
import token_shoken/handlers/register_user
import wisp
import wisp/wisp_mist

pub fn router(ctx: app.Context) {
  fn(req: wisp.Request) -> wisp.Response {
    use <- wisp.log_request(req)

    case wisp.path_segments(req) {
      ["api", "health"] -> health_check.handler(req)
      ["api", "users"] -> {
        use <- wisp.require_method(req, http.Post)
        register_user.handler(req)
      }
      ["api", "auth-with-password"] -> {
        use <- wisp.require_method(req, http.Post)
        auth_with_password.handler(req, ctx)
      }
      _ -> wisp.not_found()
    }
  }
}

pub fn main() {
  dot.new()
  |> dot.set_path(".env")
  |> dot.set_debug(False)
  |> dot.load

  wisp.configure_logger()

  let assert Ok(_) =
    wisp_mist.handler(
      router(app.Context),
      env.get_string_or("SECRET_KEY", "someappsecret"),
    )
    |> mist.new
    |> mist.port(env.get_int_or("APP_PORT", 8000))
    |> mist.start_http

  process.sleep_forever()
}
