import gleeunit
import mnemosyne

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let name = "Joe"
  let greeting = "Hello, " <> name <> "!"

  assert greeting == "Hello, Joe!"
}

pub fn parse_qs_decodes_percent_test() {
  let qs = "title=Hello%20World+Again"
  let expected = [#("title", "Hello World Again")]
  assert mnemosyne.parse_qs(qs) == expected
}
