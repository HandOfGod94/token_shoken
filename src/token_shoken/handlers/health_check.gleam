import gleam/json
import wisp

type HealthCheckResponse {
  HealthCheckResponse(status: Bool)
}

fn to_json(resp: HealthCheckResponse) -> json.Json {
  json.object([#("status", json.bool(resp.status))])
}

pub fn handler(_req: wisp.Request) -> wisp.Response {
  HealthCheckResponse(status: True)
  |> to_json
  |> json.to_string_tree
  |> wisp.json_response(200)
}
