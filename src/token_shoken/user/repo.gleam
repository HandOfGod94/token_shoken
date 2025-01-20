import cake
import cake/insert as i
import cake/select as s
import cake/where as w

pub fn fetch_user_by_username(username: String) -> cake.ReadQuery {
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

pub fn create_user(
  username: String,
  password: String,
  email: String,
  is_active: Bool,
) -> cake.WriteQuery(List(Int)) {
  [
    [i.string(username), i.string(password), i.string(email), i.bool(is_active)]
    |> i.row,
  ]
  |> i.from_values(table_name: "users", columns: [
    "username", "password", "email", "is_active",
  ])
  |> i.returning(["id"])
  |> i.to_query
}
