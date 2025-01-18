import app
import birl
import cake/adapter/sqlite
import cake/select as s
import cake/where as w
import db_utils
import gleam/dynamic
import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result

pub type User {
  User(
    id: Int,
    email: String,
    username: String,
    name: String,
    password: String,
    is_active: Bool,
    is_verified: Bool,
    created_at: birl.Time,
    updated_at: Option(birl.Time),
  )
}

fn fetch_user_by_username(username: String) {
  s.new()
  |> s.selects([
    s.col("id"),
    s.col("email"),
    s.col("username"),
    s.col("name"),
    s.col("password"),
    s.col("is_active"),
    s.col("is_verified"),
    s.col("created_at"),
    s.col("updated_at"),
  ])
  |> s.from_table("users")
  |> s.where(w.col("username") |> w.eq(w.string(username)))
  |> s.limit(1)
  |> s.to_query
}

fn to_user(row) {
  row
  |> dynamic.from
  |> io.debug
  |> dynamic.decode9(
    User,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.string),
    dynamic.element(4, dynamic.string),
    dynamic.element(5, db_utils.dynamic_sqlite_bool),
    dynamic.element(6, db_utils.dynamic_sqlite_bool),
    dynamic.element(7, db_utils.dynamic_sqlite_datettime),
    dynamic.element(8, dynamic.optional(db_utils.dynamic_sqlite_datettime)),
  )
  |> io.debug
}

pub fn to_json(user: User) -> json.Json {
  [
    #("id", json.int(user.id)),
    #("email", json.string(user.email)),
    #("username", json.string(user.username)),
    #("name", json.string(user.name)),
    #("is_active", json.bool(user.is_active)),
    #("is_verified", json.bool(user.is_verified)),
    #("created_at", json.string(user.created_at |> birl.to_http)),
    #(
      "updated_at",
      user.updated_at
        |> option.map(birl.to_http)
        |> option.unwrap("")
        |> json.string,
    ),
  ]
  |> json.object
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

  io.debug(to_json(user) |> json.to_string)
  Ok(user)
}
