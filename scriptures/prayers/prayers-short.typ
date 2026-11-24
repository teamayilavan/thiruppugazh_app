// அருணகிரிநாதரின் சிறு வேண்டுதல்கள்: the prayers of fewer than 6 lines, as plain text.
// Lyrics are word-separated (பதம் பிரித்தது); data from scripts/make_short.py.
#let data = json(sys.inputs.at("data", default: "prayers-ta-short.json"))

#let green = rgb("#196519")
#let ink = rgb("#0D3619")
#let muted = rgb("#5E7A66")
#let leaf = rgb("#B3D8A8")

#set document(title: "அருணகிரிநாதரின் சிறு வேண்டுதல்கள்")
#set text(font: ("Lohit Tamil", "FreeSerif"), lang: "ta", size: 11pt, fill: ink)
#set par(justify: false, leading: 0.75em)
#set page(
  paper: "a4",
  margin: (x: 24mm, top: 22mm, bottom: 22mm),
  footer: context {
    set text(size: 8pt, fill: muted)
    if counter(page).get().first() > 1 [
      அருணகிரிநாதரின் சிறு வேண்டுதல்கள்
      #h(1fr)
      #counter(page).display()
    ]
  },
)

// ---- Title
#align(center)[
  #text(size: 22pt, weight: "bold", fill: green)[அருணகிரிநாதரின் சிறு வேண்டுதல்கள்]
  #v(3mm)
  #text(size: 10.5pt, fill: muted)[திருப்புகழில் ஆறு வரிகளுக்குக் குறைவான #data.len() வேண்டுதல்கள், பதம் பிரித்த வரிகளும் பொருளும்]
]
#v(8mm)

// ---- Prayers, one after another; a prayer never splits across pages.
#for e in data {
  block(breakable: false, width: 100%, below: 0pt)[
    #text(size: 10pt, weight: "bold", fill: green)[#e.id]
    #h(2mm)
    #text(size: 10pt, weight: "bold")[#e.title]
    #h(1fr)
    #text(size: 9pt, fill: muted)[#e.place]
    #v(3mm)

    #block(inset: (left: 4mm))[
      #set text(size: 12.5pt)
      #set par(leading: 0.95em)
      #show regex("\([^)]+\)"): it => text(fill: muted, it)
      #e.lines.join(linebreak())
    ]
    #v(3mm)

    #text(size: 8pt, weight: "bold", fill: muted, tracking: 0.05em)[பொருள்]
    #v(0.5mm)
    #block(inset: (left: 4mm))[
      #set text(size: 10pt, fill: muted.darken(25%))
      #set par(leading: 0.7em, justify: true)
      #e.ta
    ]
    #v(6mm)
    #line(length: 100%, stroke: 0.5pt + leaf)
    #v(6mm)
  ]
}
