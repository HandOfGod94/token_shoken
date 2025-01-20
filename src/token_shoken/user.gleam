import antigone
import birl
import cake/adapter/sqlite
import gleam/bit_array
import gleam/bool
import gleam/dynamic
import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import token_shoken/app
import token_shoken/db_utils
import token_shoken/user/repo

pub type User {
  User(
    id: Int,
    email: String,
    username: String,
    name: Option(String),
    password: String,
    is_active: Bool,
    is_verified: Bool,
    created_at: birl.Time,
    updated_at: Option(birl.Time),
  )
}

pub fn to_json(user: User) -> json.Json {
  [
    #("id", json.int(user.id)),
    #("email", json.string(user.email)),
    #("username", json.string(user.username)),
    #("name", json.string(user.name |> option.unwrap(""))),
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
  use rows <- result.try(
    username
    |> repo.fetch_user_by_username()
    |> sqlite.run_read_query(decode.dynamic, db)
    |> result.map_error(fn(err) {
      io.debug(err)
      Nil
    }),
  )
  use user <- result.try(
    rows
    |> list.find_map(to_user),
  )

  Ok(user)
}

pub fn create_user(
  username username: String,
  password password: String,
  email email: String,
) -> Result(Int, Nil) {
  let password_hash =
    antigone.hasher()
    |> antigone.hash(bit_array.from_string(password))

  use db <- app.with_db_conn
  use dbres <- result.try(
    repo.create_user(username, password_hash, email, True)
    |> sqlite.run_write_query(decode.list(of: decode.int), db)
    |> result.map_error(fn(err) {
      io.debug(err)
      Nil
    }),
  )
  use id <- result.try(
    dbres
    |> list.flatten
    |> list.first,
  )
  use <- bool.guard(id == 0, Error(Nil))

  Ok(id)
}

fn to_user(row) -> Result(User, List(dynamic.DecodeError)) {
  row
  |> dynamic.from
  |> dynamic.decode9(
    User,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.optional(dynamic.string)),
    dynamic.element(4, dynamic.string),
    dynamic.element(5, db_utils.dynamic_sqlite_bool),
    dynamic.element(6, db_utils.dynamic_sqlite_bool),
    dynamic.element(7, db_utils.dynamic_sqlite_datettime),
    dynamic.element(8, dynamic.optional(db_utils.dynamic_sqlite_datettime)),
  )
}
