import gleam/dynamic/decode
import sqlight

pub type Link {
  Link(id: Int, url: String, title: String)
}

const db_path = "file:links.db"

// Adds a link (url, title) to the SQLite database
pub fn add_link(url: String, title: String) -> Nil {
  sqlight.with_connection(db_path, fn(conn) {
    let _ =
      sqlight.exec(
        "insert into links (url, title) values ('"
          <> url
          <> "', '"
          <> title
          <> "')",
        on: conn,
      )
    Nil
  })
}

// Gets all links from the SQLite database
pub fn get_all() -> List(Link) {
  sqlight.with_connection(db_path, fn(conn) {
    let decoder = {
      use id <- decode.field(0, decode.int)
      use url <- decode.field(1, decode.string)
      use title <- decode.field(2, decode.string)
      decode.success(Link(id: id, url: url, title: title))
    }
    case
      sqlight.query(
        "select id, url, title from links order by id desc",
        on: conn,
        with: [],
        expecting: decoder,
      )
    {
      Ok(links) -> links
      Error(_) -> []
    }
  })
}
// This is not ideal for production but demonstrates the concept
