import app
import cake/adapter/sqlite
import cake/select as s
import cake/where as w
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/result

pub type User {
  User(username: String, password: String)
}

fn fetch_user_by_username(username: String) {
  s.new()
  |> s.selects([s.col("username"), s.col("password")])
  |> s.from_table("users")
  |> s.where(w.col("username") |> w.eq(w.string(username)))
  |> s.limit(1)
  |> s.to_query
}

fn to_user(row) {
  row
  |> dynamic.from
  |> dynamic.decode2(
    User,
    dynamic.element(0, dynamic.string),
    dynamic.element(1, dynamic.string),
  )
}

pub fn get_user(username: String) -> Result(User, Nil) {
  use db <- app.with_db_conn
  let db_res =
    username
    |> fetch_user_by_username()
    |> sqlite.run_read_query(decode.dynamic, db)

  use rows <- result.try(db_res |> result.map_error(fn(_) { Nil }))
  use user <- result.try(
    rows
    |> list.find_map(to_user),
  )
  Ok(user)
}
