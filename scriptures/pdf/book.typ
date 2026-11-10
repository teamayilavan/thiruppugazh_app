// Stories in the Thiruppugazh: the stories the songs allude to, with the songs and the sources.
// Data comes from make_pdf.py (JSON). Build: python -I -X utf8 scriptures/scripts/make_pdf.py
#let data = json(sys.inputs.data)
#let verses-only = data.edition == "verses"

// Murugan's green: the peacock and the hills of the Tamil land.
#let green = rgb("#1f6045")
#let green-dark = rgb("#134631")
#let gold = rgb("#a58633")
#let ink = rgb("#1b1d1b")
#let mute = rgb("#65706a")
#let hair = rgb("#d3ddd6")
#let wash = rgb("#eef4ef")
#let panel-bg = rgb("#f5f9f6")
#let panel-head = rgb("#e1eee6")
#let panel-line = rgb("#b4cebe")
#let mark = rgb("#f2e49c")

#let body-font = ("Cambria", "Nirmala UI")
#let tamil-font = ("Nirmala UI", "Cambria")

#set document(title: data.title_line, author: "Ayilavan")
#set text(font: body-font, size: 11pt, fill: ink, lang: "en", hyphenate: false)
#set par(justify: false, leading: 0.9em, spacing: 1.25em)

// ---------------------------------------------------------------- helpers
#let tag(body) = text(size: 8pt, weight: "bold", fill: gold, tracking: 0.12em, upper(body))
#let section(body) = block(above: 2.2em, below: 1em, sticky: true)[
  #text(size: 9pt, weight: "bold", fill: green, tracking: 0.14em, upper(body))
  #v(-0.5em)
  #line(length: 100%, stroke: 0.6pt + hair)
]
#let breakable(u) = u.replace("/", "/\u{200B}").replace("&", "&\u{200B}").replace("?", "?\u{200B}")

// One song, set apart like a fenced block: a header strip (number, opening words, shrine, tune) and the lines, centred.
#let song-panel(sg) = {
  let lines-of(group) = for ln in group {
    if ln.hit { highlight(fill: mark, extent: 2pt, radius: 1pt)[#text(weight: "bold")[#ln.t]] } else { [#ln.t] }
    linebreak()
  }
  [#block(width: 100%, breakable: true, stroke: 0.7pt + panel-line, radius: 4pt, above: 0.4em, below: 0em)[
    #block(width: 100%, fill: panel-head, inset: (x: 13pt, y: 9pt), radius: (top-left: 4pt, top-right: 4pt), sticky: true, above: 0pt, below: 0pt)[
      #text(font: tamil-font, size: 8.8pt, weight: "bold", fill: green)[பாடல் #sg.no]\
      #text(font: tamil-font, size: 13pt, weight: "bold", fill: green-dark)[#sg.name]\
      #text(font: tamil-font, size: 8.6pt, fill: mute)[#if sg.place != "" [#sg.place]#if sg.place != "" and sg.tune != "" [  ·  ]#if sg.tune != "" [#sg.tune]]
    ]
    #block(width: 100%, fill: panel-bg, inset: (x: 14pt, y: 13pt), radius: (bottom-left: 4pt, bottom-right: 4pt), above: 0pt, below: 0pt)[
      #set text(font: tamil-font, size: 9.4pt)
      #set par(leading: 0.8em, spacing: 0.3em)
      #align(center)[
        #if sg.at("first", default: false) [
          #for (vi, vs) in sg.full.enumerate() [
            #if vi > 0 [#v(0.95em)]
            #lines-of(vs)
          ]
        ] else [
          #for (vi, g) in sg.refs.enumerate() [
            #if vi > 0 [#v(0.8em)]
            #lines-of(g)
          ]
          #if sg.at("xref", default: false) [
            #v(0.9em)
            #text(size: 8.4pt, fill: mute)[முழுப் பாடல்: பக்கம் #context counter(page).at(label("song-" + str(sg.no))).first()]
          ]
        ]
      ]
    ]
  ]#if sg.at("first", default: false) [#metadata(none)#label("song-" + str(sg.no))]]
}

// ---------------------------------------------------------------- cover: the title only
#set page(paper: "a4", margin: (x: 26mm, top: 28mm, bottom: 26mm), fill: white)
#page(margin: 0pt, header: none, footer: none)[
  #rect(width: 100%, height: 100%, fill: rgb("#f3f8f3"), stroke: none)[
    #place(top + left, rect(width: 100%, height: 16mm, fill: green, stroke: none))
    #place(top + left, dy: 16mm, rect(width: 100%, height: 1.2mm, fill: gold, stroke: none))
    #pad(x: 28mm, top: 88mm)[
      #text(font: tamil-font, size: 50pt, fill: green, weight: "bold")[திருப்புகழில்]
      #v(0mm)
      #text(font: tamil-font, size: 50pt, fill: green, weight: "bold")[கதைகள்]
      #v(9mm)
      #line(length: 40mm, stroke: 1.4pt + gold)
      #v(9mm)
      #text(size: 34pt, fill: ink, weight: "bold")[#if verses-only [Stories in the\ Thiruppugazh] else [Stories in the\ Thiruppugazh]]
      #if verses-only [
        #v(3mm)
        #text(size: 18pt, fill: green, style: "italic")[The Verses]
      ]
      #v(10mm)
      #text(size: 13pt, fill: mute, tracking: 0.04em)[#data.volume_line]
    ]
  ]
]

// ---------------------------------------------------------------- running header and footer
#set page(
  header: context {
    let n = counter(page).get().first()
    if n > 1 {
      let hs = query(heading.where(level: 1)).filter(h => counter(page).at(h.location()).first() <= n)
      let t = if hs.len() > 0 { hs.last().body } else { [] }
      set text(size: 8.5pt, fill: mute)
      grid(columns: (1fr, auto), [#data.title_line · #data.volume_line], text(style: "italic")[#t])
      v(-0.6em)
      line(length: 100%, stroke: 0.5pt + hair)
    }
  },
  footer: context {
    set text(size: 9pt, fill: mute)
    grid(columns: (1fr, auto, 1fr), [], counter(page).display(), align(right, link(<toc>)[#text(fill: green)[Contents]]))
  },
)
#counter(page).update(2)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(width: 100%, above: 0pt, below: 0.4em)[
    #text(size: 22pt, weight: "bold", fill: green)[#it.body]
  ]
}

// ---------------------------------------------------------------- contents
#heading(level: 1)[Contents] <toc>
#v(0.6em)
#for (i, s) in data.stories.enumerate() [
  #block(above: 0.85em, below: 0em, breakable: false)[
    #link(label(s.slug))[#grid(columns: (9mm, auto, 1fr, auto), column-gutter: 5pt,
      text(fill: gold, weight: "bold")[#(i + 1)],
      [#s.title],
      box(width: 100%, repeat(text(fill: hair)[ .], gap: 1pt)),
      [#context counter(page).at(label(s.slug)).first()])]
  ]
]

// ---------------------------------------------------------------- introduction
#heading(level: 1)[Introduction]
#v(0.8em)
#set par(justify: true)

Arunagirinathar, the Tamil saint-poet of the fifteenth century, composed the Thiruppugazh in praise of Murugan at the shrines he visited from Tiruvannamalai to Tiruchendur and Palani. The 1,340 songs now preserved are set to rhythms that the poet notes at the head of each song in the syllables of its tune, and in the midst of their praise of Murugan they carry a great store of stories: of Vishnu's avatars and the Ramayana and Mahabharata, of the deeds of Shiva, of the Goddess, of the saints of the Tamil country, and of Murugan's own exploits.

The poet seldom tells a story at length. He names it in a line or half a line, trusting that the devotee will know the rest: the elephant that cried "Mulame!", the stone that became a woman at Rama's feet, the poison on Shiva's throat, the hunter's daughter in the millet field. To a reader who does not know the tale, the line passes by. This book is meant to give the rest.

This volume, #data.volume_line, holds #data.n_stories stories. Each is told from the texts that carry it, such as Valmiki's Ramayana and Kamban's, the Mahabharata, the Bhagavata and other Puranas, the Kanda Puranam, the Periya Puranam, the Tiruvilaiyadal Puranam, the Tevaram and the Divya Prabandham, and each keeps close to what those texts say.
#if verses-only [
  After the story come the lines of the Thiruppugazh in which Arunagiri refers to it, set apart and highlighted; the complete songs and their meanings are in the full edition of this volume.
] else [
  After the story come the songs in which Arunagiri refers to it: each song is printed in full, in its verses, with the lines that carry the allusion highlighted, and followed by its meaning in Tamil. A song that serves several stories is printed in full once; later stories give the lines and the page of the full song.
]
At the end of each story are the passages in the texts, and the pages from which they were read, so that every statement can be followed to its source.

The stories are in alphabetical order, one after another, so that the volume can be read as a collection or consulted through the contents at the front, which gives every story its chapter number and links to it, and the index of songs at the end, which lists every song with the stories it appears in.

#v(1.2em)
#text(size: 9.5pt, fill: mute)[The text of the songs and their meanings follow the Thiruppugazh edition made available digitally by Kaumaram.com, as used in the Thiruppugazh app. Where a passage in a source text could not be read, the story says so and rests on the songs and on tradition.]

// ---------------------------------------------------------------- the stories
#set par(justify: false)
#for (i, s) in data.stories.enumerate() [
  #heading(level: 1)[#(i + 1). #s.title] #label(s.slug)
  #v(0.2em)
  #tag[#s.domain]
  #v(1.3em)

  #set par(justify: true)
  #for (i, p) in s.story.enumerate() {
    if i == 0 { text(size: 11.6pt)[#p] } else { [#p] }
    parbreak()
  }
  #set par(justify: false)

  #if s.songs.len() > 0 [
    #section[#if verses-only [The lines in the songs] else [The story in the songs]]
    #text(size: 10pt, fill: mute)[#if verses-only [#s.songs.len() song#if s.songs.len() != 1 [s] carr#if s.songs.len() == 1 [ies] else [y] the story in a line of verse. The lines that carry it are highlighted.] else [#(s.songs.len() + 0) song#if s.songs.len() != 1 [s] of the Thiruppugazh allude#if s.songs.len() == 1 [s] to this story. The lines that carry the allusion are highlighted.]]
    #v(0.4em)
    #for (i, sg) in s.songs.enumerate() [
      #v(1.5em)
      #song-panel(sg)
      #if not verses-only and sg.at("first", default: false) and sg.meaning != "" [
        #block(above: 1.1em, below: 0.4em, breakable: true)[
          #text(font: tamil-font, size: 8.8pt, weight: "bold", fill: gold)[பொருள்]
          #v(0.15em)
          #set par(leading: 0.85em, justify: false)
          #text(font: tamil-font, size: 10pt, fill: rgb("#2a2e2b"))[#sg.meaning]
        ]
      ]
    ]
  ]
  #if s.nohit.len() > 0 [
    #v(1.4em)
    #text(size: 9.6pt, fill: mute)[Further songs allude to this story in their meaning rather than in a single line of verse: #s.nohit.map(x => [#x.no #text(font: tamil-font)[#x.name]]).join([; ]).]
  ]

  #if s.refs.len() > 0 [
    #section[Sources and references]
    #set text(size: 9.6pt)
    #set par(leading: 0.7em)
    #table(
      columns: (1.05fr, 1.15fr, 1.9fr),
      stroke: (x, y) => (bottom: 0.45pt + hair),
      fill: (x, y) => if y == 0 { wash } else { none },
      inset: (x: 6pt, y: 6pt),
      table.header(
        text(weight: "bold", fill: green)[Text], text(weight: "bold", fill: green)[Passage], text(weight: "bold", fill: green)[What it tells],
      ),
      ..for r in s.refs {
        if r.says == "" { ([#r.source], table.cell(colspan: 2)[#r.ref]) } else { ([#r.source], [#r.ref], [#text(font: tamil-font)[#r.says]]) }
      },
    )
  ]

  #if s.links.len() > 0 [
    #section[Where to read the sources]
    #set text(size: 8.6pt)
    #for (i, l) in s.links.enumerate() [
      #block(above: 0.7em, below: 0em, breakable: false)[
        #grid(columns: (8mm, 1fr), column-gutter: 2pt,
          text(fill: gold, weight: "bold")[#(i + 1)],
          [#text(fill: ink)[#l.label]\
           #link(l.url)[#text(fill: rgb("#1d4f8c"), font: ("Consolas", "Cambria"), size: 7.6pt)[#breakable(l.show)]]],
        )
      ]
    ]
  ]
]

// ---------------------------------------------------------------- sources
#heading(level: 1)[Sources]
#v(0.6em)
#set par(justify: true)
The stories in this volume are told from the following texts. For each, the list gives the place where the text was read; the exact passages are given at the end of every story.
#v(0.8em)
#set par(justify: false)
#for src in data.sources [
  #block(above: 0.7em, below: 0em, breakable: false)[
    #text(weight: "bold")[#src.name]\
    #text(size: 9pt, fill: mute)[#src.urls.join(", ")]
  ]
]
#v(2em)
#text(size: 9.5pt, fill: mute)[Song texts and meanings: the Thiruppugazh as made available by Kaumaram.com.]

// ---------------------------------------------------------------- index of songs (at the end)
#heading(level: 1)[Index of songs]
#v(0.4em)
#text(size: 10pt, fill: mute)[The number of the song in the Thiruppugazh, its opening words and the shrine, then the stories in which it appears, with the page.]
#v(0.8em)
#let by-slug = (:)
#let chap-of = (:)
#for (i, s) in data.stories.enumerate() { by-slug.insert(s.slug, s); chap-of.insert(s.slug, i + 1) }
#columns(2, gutter: 10mm)[
  #set text(size: 9.2pt)
  #set par(leading: 0.65em, spacing: 0.9em)
  #for sg in data.songs [
    #block(above: 0.85em, below: 0em, breakable: false)[
      #text(weight: "bold", fill: green)[#sg.no]#h(4pt)#text(font: tamil-font)[#sg.name]#if sg.place != "" [ #text(fill: mute, font: tamil-font)[(#sg.place)]]\
      #for (i, sl) in sg.stories.enumerate() [
        #if i > 0 [; ]#link(label(sl))[#chap-of.at(sl). #by-slug.at(sl).title, p. #context counter(page).at(label(sl)).first()]
      ]
    ]
  ]
]
