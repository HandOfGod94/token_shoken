import gleam/erlang/process
import gleam/json
import mist
import wisp
import wisp/wisp_mist

pub fn router(req: wisp.Request) -> wisp.Response {
  use <- wisp.log_request(req)
  case wisp.path_segments(req) {
    ["api", "health"] -> {
      [#("success", json.bool(True))]
      |> json.object
      |> json.to_string_tree
      |> wisp.json_response(200)
    }
    _ -> wisp.not_found()
  }
}

pub fn main() {
  wisp.configure_logger()

  let assert Ok(_) =
    wisp_mist.handler(router, "secret_key")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
