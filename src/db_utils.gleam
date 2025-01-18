import birl
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/result

pub fn dynamic_sqlite_bool(from: Dynamic) -> Result(Bool, List(DecodeError)) {
  dynamic.int(from)
  |> result.map(fn(x) { x == 1 })
}

pub fn dynamic_sqlite_datettime(
  from: Dynamic,
) -> Result(birl.Time, List(DecodeError)) {
  use raw_datetime <- result.try(dynamic.int(from))
  raw_datetime
  |> birl.from_unix()
  |> Ok
}
