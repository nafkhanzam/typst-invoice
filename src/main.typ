#import "@preview/tablex:0.0.8": gridx, hlinex

#let data = toml("data.toml")

#{
  if not data.keys().contains("date") {
    data.date = datetime.today().display("[day] [month repr:long] [year]")
  }
  data.items = data.items.map(item => {
    if item.at("rate") != none and item.at("unit") != none {
      item.price = item.rate * item.unit
    }
    item
  })
}

#set page(
  paper: "a4",
  margin: (x: 10%, y: 10%),
)

#let round-fixed-str(num, d) = {
  let res = str(calc.round(num, digits: d))
  let pad = res.split(".")
  let post-len = 0
  if pad.len() < 2 {
    if d != none and d > 0 {
      res += "."
    }
  } else if pad.len() >= 2 {
    post-len = pad.at(1).len()
  }
  pad = d - post-len
  while pad > 0 {
    res += "0"
    pad -= 1
  }
  return res
}

#let print-number(num, prefix: none, splitter: [,], split-num: 3, d: 0, comma: ".") = {
  if num < 0 [\- ]
  [#prefix]
  num = calc.abs(num)
  let res = str(num)
  if d != none {
    res = round-fixed-str(num, d)
    res = res.replace(".", comma)
  }
  let res-split = res.split(comma)
  let left = res-split.at(0)
  let right = res-split.at(1, default: none)
  let mod = calc.rem(left.len(), split-num)
  [#left.slice(0, mod)]
  let i = mod
  while i < left.len() {
    if i > 0 {
      splitter
    }
    [#left.slice(i, i + split-num)]
    i += split-num
  }
  if right != none {
    comma + [#right]
  }
}

#let format_currency(number) = {
  print-number(number, prefix: data.prefix, splitter: data.splitter, d: data.d, comma: data.comma)
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
  ([#item.date], [#item.description], [], [#format_currency(item.price)])
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
    [#format_currency(total)],
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
