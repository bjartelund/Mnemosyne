import gleam/list
import lustre/attribute as attr
import lustre/element
import lustre/element/html

import link_store.{type Link}

pub fn page(links: List(Link)) -> element.Element(a) {
  let items =
    links
    |> list.map(fn(l) {
      html.li([], [
        html.a([attr.href(l.url), attr.target("_blank")], [
          html.text(l.title <> " →"),
        ]),
      ])
    })

  html.html([], [
    html.head([], [
      html.meta([attr.charset("utf-8")]),
      html.meta([
        attr.name("viewport"),
        attr.content("width=device-width, initial-scale=1"),
      ]),
      html.title([], "Read later"),
    ]),
    html.body(
      [
        attr.attribute(
          "style",
          "max-width:720px;margin:2rem auto;font-family:system-ui,sans-serif",
        ),
      ],
      [
        html.h1([], [html.text("Read later")]),
        html.form(
          [
            attr.method("GET"),
            attr.action("/add"),
            attr.attribute(
              "style",
              "display:flex;gap:.5rem;flex-wrap:wrap;margin:.5rem 0 1rem",
            ),
          ],
          [
            html.input([
              attr.type_("url"),
              attr.name("url"),
              attr.placeholder("https://…"),
              attr.required(True),
              attr.attribute("style", "flex:2;min-width:260px;padding:.5rem"),
            ]),
            html.input([
              attr.type_("text"),
              attr.name("title"),
              attr.placeholder("Tittel"),
              attr.required(True),
              attr.attribute("style", "flex:1;min-width:200px;padding:.5rem"),
            ]),
            html.button([attr.type_("submit")], [html.text("Lagre")]),
          ],
        ),
        html.h2([], [html.text("Lenker")]),
        html.ul(
          [
            attr.attribute(
              "style",
              "display:flex;flex-direction:column;gap:.25rem;padding-left:1rem",
            ),
          ],
          items,
        ),
      ],
    ),
  ])
}
