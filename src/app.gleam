import cake/adapter/sqlite
import sqlight

pub type Context {
  Context
}

pub fn with_db_conn(callback: fn(sqlight.Connection) -> a) -> a {
  let filename = "./db/data.db"
  sqlite.with_connection(filename, callback)
}
