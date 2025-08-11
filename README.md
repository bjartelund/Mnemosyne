# mnemosyne

[![Package Version](https://img.shields.io/hexpm/v/mnemosyne)](https://hex.pm/packages/mnemosyne)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/mnemosyne/)

```sh
gleam add mnemosyne@1
```
```gleam
import mnemosyne

pub fn main() -> Nil {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/mnemosyne>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Bookmarklet

Links can be added directly from the browser using the `/add/confirm` route:

```
/add/confirm?url=<URL>&title=<TITLE>
```

The link is stored and the response redirects back to the provided URL
with a plain text confirmation, making it suitable for bookmarklets.
