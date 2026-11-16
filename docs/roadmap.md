# Roadmap

What is planned for the app. Shipped work is in [`CHANGELOG.md`](../CHANGELOG.md); this
file is only for what is coming. New work lands on `next`, soaks, then merges to `main`.

## Next

### Discover features (built on `next`, ships with the next release)

An opt-in page of short feature cards so people who open the app, read and close it can find
the rest. Done: the Discover page (14 cards; the tablet reading-pane card only on large
screens), a **Discover features** row in Settings, and a dismissible card on Home. Eight
cards have a **Try it** button; the rest explain how to use the feature. One device-side
preference (`discover_card_dismissed`); no database, schema or backup change.

Still to do before release:

- A native Tamil speaker reads the Tamil card wording.
- Check the release build on a device (English, dark theme, a tablet-size window).
- Add a card whenever a release adds a feature (`discoverFeatures()` in
  `lib/ui/screens/discover_screen.dart`).

## Exploring

Nothing committed yet. Ideas are kept in `docs/superpowers/notes/` (local) until they are
designed and approved.

### Scripture stories in the app (idea, not designed, owner undecided)

Goal: let a devotee reading a song see which scripture story it alludes to. The research is
in `scriptures/` (start with `scriptures/HANDOFF.md`); none of it is bundled in the app yet.

Recommended shape (2026-11-15, not yet approved):

- **Phase 1: a "Story" note on the song page.** A collapsed section for songs that allude to
  a story: story title, a 2 to 3 sentence brief, the source references (for example Bhagavata
  8.2-3), and "also told in" other songs. No new tab; same on phones, tablets and in Tamil.
- **Phase 2: a Stories section to browse.** Grouped by deity, each story page lists its songs
  and links back. Waits for more narratives to be written (14 of 142 exist today).
- **Data:** a script turns `scriptures/*/master.json` into one bundled, read-only JSON asset.
  No database, schema or backup change, so user data is not at risk.
- **Opt-in and quiet:** collapsed by default, plus a Settings switch to hide it.
- **Content shown:** our own briefs and verse references only, with no quoted third-party text.

Open items before this can be designed or built:

1. Owner review of the briefs (`scriptures/HANDOFF.md` lists it as open). Start with the
   Vishnu and Shiva sets, whose songs were read one by one.
2. The newer sets (Murugan, Devi, saints, Sambandar, Ganesha, Tamil lore) are matched by
   keyword, so keep them out of the app until reviewed.
3. Source licences (Project Madurai needs its header page) and the unconfirmed Kaumaram.com
   credit wording. Showing only references and our own briefs avoids most of this.
4. Decide Phase 1 only, or both phases, and where Phase 2 would live (Library tab or a
   Discover card).
