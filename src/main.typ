#import "@preview/tablex:0.0.5": gridx, hlinex

#let details = toml("data.toml")

#{
  if not details.keys().contains("date") {
    details.date = datetime.today().display("[day] [month repr:long] [year]")
  }
}

#set page(
  paper: "a4",
  margin: (x: 10%, y: 10%),
)

#let round-fixed-str(num, d) = {
  let res = str(calc.round(num, digits: d))
  let pad = res.split(".")
  let post-len = 0
  if pad.len() < 2 and d != none and d > 0 {
    res += "."
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

#let print-number(num, prefix: none, splitter: [,], split-num: 3, d: 0) = {
  if num < 0 [\- ]
  [#prefix]
  num = calc.abs(num)
  let res = str(num)
  if d != none {
    res = round-fixed-str(num, d)
  }
  let res-split = res.split(".")
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
    [.#right]
  }
}

#let format_currency(number) = {
  print-number(number, prefix: [\$], splitter: ",", d: 2)
}

#set text(number-type: "old-style")

#[
  #[
    #smallcaps[
      To: #[
        #set text(size: 1.2em)
        #details.recipient.name
      ]
    ]
  ] #h(1fr) #[#details.invoice-city, #details.date]
]

#heading[
  Invoice \##details.invoice-nr
]

#let items = details.items.enumerate().map(
    ((id, item)) => (
      [#item.date],
      [#item.description],
      [],
      [#format_currency(item.price)]
    )
  ).flatten()

#let total = details.items.map((item) => item.at("price")).sum()

#[
  #set text(number-type: "lining")
  #gridx(
    columns: (auto, 1fr, auto, auto),
    align: ((column, row) => if column >= 3 { right } else { left} ),
    hlinex(stroke: (thickness: 0.5pt)),
    [*Date*], [*Description*], [], [*Cost*],
    hlinex(),
    ..items,
    hlinex(),
    [], [], [ Total:], [#format_currency(total)],
    hlinex(start: 2),
  )
]

#v(1em)

#[
  The transaction details are attached below as appendices.

  The account details to transfer to are as follows:
]

#[
  #set par(leading: 0.40em)
  #set text(number-type: "lining")
  #gridx(
    columns: 2,
    [Account holder name],[: #details.bank_account.name],
    [Bank name],[: #details.bank_account.bank],
    [Bank code],[: #details.bank_account.bank_code],
    [Account number],[: #details.bank_account.number],
  )
]

Thank you.

#h(1em)

Best regards,

#image("res/sign.png", width: 10em)

#details.author.name
