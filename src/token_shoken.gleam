import dot_env as dot
import dot_env/env
import gleam/erlang/process
import handlers/health_check
import mist
import wisp
import wisp/wisp_mist

pub fn router(req: wisp.Request) -> wisp.Response {
  use <- wisp.log_request(req)

  case wisp.path_segments(req) {
    ["api", "health"] -> health_check.handler(req)
    _ -> wisp.not_found()
  }
}

pub fn main() {
  dot.new()
  |> dot.set_path(".env")
  |> dot.set_debug(False)
  |> dot.load

  wisp.configure_logger()

  let assert Ok(_) =
    wisp_mist.handler(router, env.get_string_or("SECRET_KEY", "someappsecret"))
    |> mist.new
    |> mist.port(env.get_int_or("APP_PORT", 8000))
    |> mist.start_http

  process.sleep_forever()
}
