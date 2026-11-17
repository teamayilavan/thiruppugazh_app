// Story and song reference index for expert verification. Built by scripts/make_index.py.
#let data = json(sys.inputs.at("data", default: "story-song-index.json"))

#let green = rgb("#2e6b3a")
#let green-dark = rgb("#1f4a28")
#let pale = rgb("#eef5ee")
#let mute = rgb("#5f6b60")
#let ink = rgb("#1d241e")
#let body-font = ("Cambria", "Nirmala UI")
#let tamil-font = ("Nirmala UI", "Cambria")

#set document(title: "Stories in the Thiruppugazh: Story and Song Reference")
#set page(paper: "a4", margin: (x: 1.8cm, top: 1.8cm, bottom: 2cm),
  footer: context {
    set text(size: 8pt, fill: mute)
    if counter(page).get().first() > 1 [
      #link(<contents>)[Contents] #h(1fr) Stories in the Thiruppugazh: story and song reference #h(1fr) #counter(page).display()
    ]
  })
#set text(font: body-font, size: 10pt, fill: ink, lang: "en", hyphenate: false)
#set par(justify: true, leading: 0.6em)
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(width: 100%, fill: green, inset: (x: 10pt, y: 9pt), radius: 2pt,
    text(fill: white, size: 15pt, weight: "bold", it.body))
  v(4pt)
}
#show link: set text(fill: green-dark)

#let ta(body) = text(font: tamil-font, body)

// ---------- title page ----------
#align(center)[
  #v(5cm)
  #text(font: tamil-font, size: 34pt, fill: green, weight: "bold")[திருப்புகழில் கதைகள்]
  #v(0.4cm)
  #text(size: 22pt, fill: green-dark, weight: "bold")[Stories in the Thiruppugazh]
  #v(0.6cm)
  #text(size: 14pt)[Story and Song Reference]
  #v(0.2cm)
  #text(size: 11pt, fill: mute)[for verification]
  #v(2cm)
  #text(size: 11pt)[#data.n_stories stories · #data.n_songs songs · #data.n_entries story–song entries]
  #v(0.3cm)
  #text(size: 10pt, fill: mute)[#data.date]
]
#pagebreak()

// ---------- how to use ----------
= How to use this reference
This reference lists every story from the Puranas, the epics, the lives of the saints and Tamil tradition that the
research for *Stories in the Thiruppugazh* has found alluded to in the songs of Arunagirinathar. It is meant to be
read and checked by someone who knows the songs well.

For each story there is:
- its *number* (volume and chapter, as in the books: I Vishnu, II Shiva, III Murugan, IV Sambandar, the saints, the
  Goddess, Ganesha and Tamil lore; chapters are in alphabetical order within a volume),
- a *brief* of the story as the research understands it, with the source passages it rests on,
- the *references* that were read,
- and a *table of the Thiruppugazh songs* that refer to it: song number (as in the Kaumaram.com numbering used in the
  app), title, temple, and the lyric line or lines that carry the allusion. Where the allusion lies in the sense of
  the song rather than in a single line, the table says so.

The last column of each table is left blank for a tick or a remark. The questions most useful to the research are:
*Does this song really refer to this story? Is the line right? Is the brief right? Is a well-known song missing?*

At the end, an *index by song number* gives, for each song, the stories it is listed under. The same data is in the
accompanying Excel workbook, which has a column for remarks on every row.

The texts of the songs follow the Thiruppugazh edition made available digitally by Kaumaram.com, as used in the
Thiruppugazh app.

// ---------- contents ----------
#[= Contents #label("contents")]
#set par(justify: false)
#for vol in data.volumes [
  #v(6pt)
  #text(weight: "bold", fill: green-dark, size: 11pt)[Volume #vol.roman: #vol.name]
  #v(2pt)
  #for s in vol.stories [
    #link(label("st-" + s.id))[#box(width: 1.1cm)[#s.id] #s.title]
    #box(width: 1fr, repeat[#text(fill: rgb("#bbbbbb"))[.]])
    #text(fill: mute, size: 8.5pt)[#s.songs.len() songs]
    #h(4pt)
    #context { let p = locate(label("st-" + s.id)).page(); link(label("st-" + s.id))[p. #p] }
    \
  ]
]
#link(<songindex>)[Index by song number]

// ---------- stories ----------
#for vol in data.volumes [
  = Volume #vol.roman: #vol.name
  #for (k, s) in vol.stories.enumerate() [
    #if k > 0 { v(10pt) }
    #block(breakable: true, width: 100%)[
      #block(width: 100%, stroke: (bottom: 1pt + green), inset: (bottom: 4pt), below: 6pt)[
        #text(size: 13pt, weight: "bold", fill: green-dark)[#s.id #h(6pt) #s.title]#label("st-" + s.id)
        #h(1fr) #text(size: 8pt, fill: mute)[#s.domain · #s.songs.len() songs]
      ]
      #set par(justify: true)
      #text(weight: "bold", fill: green, size: 9pt)[BRIEF] #h(4pt) #s.brief
      #if s.refs.len() > 0 [
        #v(4pt)
        #text(weight: "bold", fill: green, size: 9pt)[REFERENCES]
        #set text(size: 8.8pt)
        #for r in s.refs [
          \ • *#r.source*#if r.ref != "" [, #r.ref]#if r.says != "" [ — #r.says]
        ]
      ]
      #v(6pt)
      #set text(size: 8.8pt)
      #set par(justify: false)
      #table(
        columns: (1.1cm, 3.4cm, 1fr, 1.6cm),
        stroke: 0.5pt + rgb("#c8d6c8"),
        inset: 4pt,
        fill: (x, y) => if y == 0 { green } else if calc.odd(y) { pale } else { none },
        table.header(
          text(fill: white, weight: "bold")[Song],
          text(fill: white, weight: "bold")[Title · temple],
          text(fill: white, weight: "bold")[Lines (the allusion in bold)],
          text(fill: white, weight: "bold")[Remark],
        ),
        ..s.songs.map(g => (
          text(weight: "bold")[#g.no],
          [#ta(g.title)#if g.place != "" [\ #text(fill: mute, size: 8pt)[#ta(g.place)]]],
          if g.ctx.len() > 0 { ta(g.ctx.map(c => if c.hit { text(weight: "bold", fill: green-dark, c.t) } else { text(fill: mute, c.t) }).join(linebreak())) } else { text(fill: mute, style: "italic")[allusion in the sense of the song, no single line] },
          [],
        )).flatten()
      )
    ]
  ]
]

// ---------- index by song ----------
#[= Index by song number #label("songindex")]
#set text(size: 8.6pt)
#table(
  columns: (1.2cm, 4.2cm, 3.6cm, 1fr),
  stroke: 0.5pt + rgb("#c8d6c8"),
  inset: 3.5pt,
  fill: (x, y) => if y == 0 { green } else if calc.odd(y) { pale } else { none },
  table.header(
    text(fill: white, weight: "bold")[Song],
    text(fill: white, weight: "bold")[Title],
    text(fill: white, weight: "bold")[Temple],
    text(fill: white, weight: "bold")[Stories],
  ),
  ..data.songs.map(g => (
    text(weight: "bold")[#g.no],
    ta(g.title),
    ta(g.place),
    g.stories.map(x => link(label("st-" + x.id))[#x.id #x.title]).join("; "),
  )).flatten()
)
