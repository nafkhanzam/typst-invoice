#import "@preview/tablex:0.0.8": gridx, hlinex
#import "@nafkhanzam/common:0.0.1": *

#let data = toml("data.toml")

#{
  if not data.keys().contains("date") {
    data.date = datetime.today().display("[day] [month repr:long] [year]")
  }
  data.items = data.items.map(item => {
    if item.at("rate", default: none) != none and item.at("unit", default: none) != none {
      item.price = item.rate * item.unit
    }
    item
  })
}

#set page(
  paper: "a4",
  margin: (x: 10%, y: 10%),
)

#let format-currency(number) = {
  print-currency(number, prefix: data.prefix, splitter: data.splitter, d: data.d, comma: data.comma)
}

#set text(number-type: "old-style")

#[
  #{
    if (data.recipient.name != none) and (data.recipient.name != "") {
      smallcaps[
        To: #[
          #set text(size: 1.2em)
          #data.recipient.name
        ]
      ]
    } else {
      []
    }
  } #h(1fr) #[#data.invoice-city, #data.date]
]

#heading[
  Invoice \##data.invoice-nr
]

#let items = data.items.map(item => {
  if item.at("rate", default: none) != none and item.at("unit", default: none) != none {
    item.description = [#item.description (#item.unit $times$ #format_currency(item.rate))]
  }
  ([#item.date], [#item.description], [], [#format-currency(item.price)])
}).flatten()

#let total = data.items.map(item => item.at("price")).sum()

#[
  #set text(number-type: "lining")
  #gridx(
    columns: (auto, 1fr, auto, auto),
    align: (
      (column, row) => if column >= 3 {
        right
      } else {
        left
      }
    ),
    hlinex(stroke: (thickness: 0.5pt)),
    [*Date*],
    [*Description*],
    [],
    [*Cost*],
    hlinex(),
    ..items,
    hlinex(),
    [],
    [],
    [ Total:],
    [#format-currency(total)],
    hlinex(start: 2),
  )
]

#v(1em)

#{
  let has-desc = data.keys().contains("description") and data.description.len() > 0
  let is-paid = data.keys().contains("paid") and data.paid
  if is-paid {
    if has-desc {
      [#data.description \ ]
    } else [
      Hereby declare that the invoice has been paid full by #data.recipient.name to #data.author.name.
    ]
  } else {
    if has-desc {
      [#data.description \ ]
    }
    [The account details to transfer to are as follows:]
    {
      set par(leading: 0.40em)
      set text(number-type: "lining")
      gridx(
        columns: 2,
        [Account holder name],
        [: #data.bank_account.name],
        [Bank name],
        [: #data.bank_account.bank],
        [Bank code],
        [: #data.bank_account.bank_code],
        [Account number],
        [: #data.bank_account.number],
      )
    }
  }
}

Thank you.

#h(1em)

Best regards,

#image("res/sign.png", width: 10em)

#data.author.name
