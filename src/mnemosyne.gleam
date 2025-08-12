import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request as req
import gleam/http/response as res
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/uri
import lustre/element
import mist

import link_store as links_store
import view

pub fn main() {
  // Forhåndsgenerert 404-respons
  let empty = mist.Bytes(bytes_tree.new())
  let not_found = res.set_body(res.new(404), empty)

  // HTTP-handler
  let service = fn(r: req.Request(mist.Connection)) -> res.Response(
    mist.ResponseData,
  ) {
    case string.split(r.path, "/") {
      ["", ""] -> {
        let links = links_store.get_all()
        render_html(view.page(links))
      }

      ["", "add"] -> {
        let params =
          r.query
          |> option.unwrap("")
          |> uri.parse_query
          |> result.unwrap([])
        let url = dict_get(params, "url") |> option.unwrap("")
        let title = dict_get(params, "title") |> option.unwrap(url)
        case url {
          "" -> redirect("/")
          _ -> {
            links_store.add_link(url, title)
            redirect("/")
          }
        }
      }

      _ -> not_found
    }
  }

  // Start Mist
  let assert Ok(_) =
    service
    |> mist.new
    |> mist.port(3001)
    |> mist.start

  process.sleep_forever()
}

fn redirect(location: String) -> res.Response(mist.ResponseData) {
  res.new(302)
  |> res.set_header("Location", location)
  |> res.set_body(mist.Bytes(bytes_tree.from_string("")))
}

fn render_html(el) -> res.Response(mist.ResponseData) {
  let html = element.to_document_string(el)
  res.new(200)
  |> res.set_header("content-type", "text/html; charset=utf-8")
  |> res.set_body(mist.Bytes(bytes_tree.from_string(html)))
}

fn dict_get(ps: List(#(String, String)), key: String) -> option.Option(String) {
  case
    list.find(ps, fn(pair) {
      let #(k, _) = pair
      k == key
    })
  {
    Ok(#(_, v)) -> option.Some(v)
    Error(_) -> option.None
  }
}
