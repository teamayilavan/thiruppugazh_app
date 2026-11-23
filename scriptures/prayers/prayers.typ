// அருணகிரிநாதரின் வேண்டுதல்கள் — one prayer per page, Tamil only.
#let data = json(sys.inputs.at("data", default: "prayers-ta.json"))

#let green = rgb("#196519")
#let ink = rgb("#0D3619")
#let muted = rgb("#476450")
#let leaf = rgb("#B3D8A8")
#let mark-bg = rgb("#FFEB3B")

#set document(title: "அருணகிரிநாதரின் வேண்டுதல்கள்")
#set text(font: ("Lohit Tamil", "FreeSerif"), lang: "ta", size: 11pt, fill: ink)
#set par(justify: false, leading: 0.75em)
#set page(
  paper: "a4",
  margin: (x: 22mm, top: 20mm, bottom: 22mm),
  footer: context {
    set text(size: 8pt, fill: muted)
    if counter(page).get().first() > 1 [
      அருணகிரிநாதரின் வேண்டுதல்கள்
      #h(1fr)
      #counter(page).display()
    ]
  },
)

// Lyric line: show the ...... break marker softly and highlight the asking word on the last line.
#let lyric-line(line, word, last) = {
  let soft(s) = s.split("......").map(p => p.trim()).join(text(fill: muted)[ …… ])
  let ms = if last and word != "" { line.matches(word) } else { () }
  if ms.len() == 0 { return soft(line) }
  let m = ms.last()
  [#soft(line.slice(0, m.start))#box(fill: mark-bg, inset: (x: 2pt), outset: (y: 3pt), radius: 2pt, text(weight: "bold", word))#line.slice(m.end)]
}

// ---- Cover
#page(footer: none)[
  #v(1fr)
  #align(center)[
    #text(size: 30pt, weight: "bold", fill: green)[அருணகிரிநாதரின்\ வேண்டுதல்கள்]
    #v(6mm)
    #text(size: 13pt, fill: muted)[திருப்புகழில் முருகப் பெருமானிடம் வைத்த #data.len() வேண்டுதல்கள்]
  ]
  #v(12mm)
  #block(inset: (x: 12mm))[
    #set text(size: 10.5pt)
    #set par(leading: 0.9em)
    திருப்புகழ்ப் பாடல்கள் பலவற்றில், அருணகிரிநாதர் முருகப் பெருமானிடம் ஒரு வேண்டுதலை வைக்கிறார். அது
    பெரும்பாலும் அருள்வாயே, தருவாயே, தாராய், வரவேணும் போன்ற சொற்களில் நிறைவு பெறுகிறது.
    இந்தத் தொகுப்பில் ஒவ்வொரு பக்கத்திலும் ஒரு வேண்டுதல் உள்ளது: பாடல் எண், தலைப்பு, தலம்,
    வேண்டுதல் அடங்கிய முழு வாக்கியம், அதன் பொருள். வேண்டும் சொல் மஞ்சள் நிறத்தில் குறிக்கப்பட்டுள்ளது.
  ]
  #v(1fr)
  #align(center, text(size: 8.5pt, fill: muted)[பாடல் வரிகளும் பொருளும் திருப்புகழ் செயலியின் தரவுத்தளத்திலிருந்து எடுக்கப்பட்டவை. பாடல் எண்கள் செயலியில் உள்ளவையே.])
]

// ---- One prayer per page
#for (i, e) in data.enumerate() {
  if i > 0 { pagebreak() }
  let n = e.lines.len()
  let size = if n > 24 { 9.5pt } else if n > 16 { 10.5pt } else if n > 8 { 12pt } else { 13pt }
  let msize = if e.ta.len() > 2200 { 9.5pt } else { 10.5pt }

  grid(
    columns: (auto, 1fr),
    column-gutter: 5mm,
    align: (left + horizon, left + horizon),
    text(size: 22pt, weight: "bold", fill: green)[#e.id],
    [
      #text(size: 15pt, weight: "bold", fill: ink)[#e.title] \
      #text(size: 10pt, fill: muted)[#e.place]
    ],
  )
  v(2mm)
  line(length: 100%, stroke: 0.6pt + leaf)
  v(5mm)

  block(inset: (left: 6mm), stroke: (left: 2pt + leaf))[
    #set text(size: size)
    #set par(leading: 1.05em)
    #for (j, l) in e.lines.enumerate() {
      lyric-line(l, e.word, j == n - 1)
      if j < n - 1 { linebreak() }
    }
  ]

  v(7mm)
  text(size: 9pt, weight: "bold", fill: green, tracking: 0.05em)[பொருள்]
  v(1mm)
  if e.ta != "" {
    set text(size: msize)
    set par(leading: 0.7em, justify: true)
    e.ta
  } else {
    text(size: 10pt, fill: muted)[இப்பாடலுக்குப் பொருள் தரவுத்தளத்தில் இல்லை.]
  }
}
