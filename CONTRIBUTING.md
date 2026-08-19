# Contributing to Thiruppugazh

Thank you for wanting to help improve this app — whether that's a bug report, a new feature, a documentation fix, or a correction to the song data itself. Contributions of every size are welcome, and this guide should get you moving quickly regardless of your experience level.

## Ways to contribute

- **Report a bug** — open an [issue](https://github.com/teamayilavan/thiruppugazh_app/issues) with steps to reproduce, what you expected, and what actually happened. Screenshots help a lot for UI issues.
- **Suggest a feature** — open an issue describing the problem you're trying to solve before jumping to a specific implementation; it's easier to find the right design together that way.
- **Fix a bug or build a feature** — see the workflow below.
- **Improve the docs** — the `docs/` folder is a normal part of the codebase, not an afterthought. If something there is confusing or out of date, a PR fixing it is just as welcome as a code change.
- **Correct song data** — lyrics, meanings, and temple names live in `songs/*.json` (compiled into `assets/thiruppugazh.db` via `scripts/build_db.py`). If you spot an inaccuracy, a fix here is genuinely valuable. (One known example: song 1328 has a data anomaly — see `docs/database.md` → Known Data Issues — if you want a concrete first task.)
- **Translations** — the app is bilingual (Tamil UI + English), with ARB files under `lib/l10n/`. Filling in gaps or improving existing translations is welcome.

## Before you start

1. Read [`docs/setup.md`](docs/setup.md) to get the app building and running locally.
2. Skim [`docs/architecture.md`](docs/architecture.md) to get a feel for how screens, state, and data flow fit together.
3. For anything non-trivial, it's worth opening an issue first to align on approach before investing significant time — saves everyone a re-write.

## Development workflow

1. Fork the repo and create a branch off `main`: `git checkout -b feat/short-description` (or `fix/`, `docs/`, `chore/` — whatever fits).
2. Make your change. Keep PRs focused — one bug fix or one feature per PR is much easier to review than a grab-bag.
3. Before opening a PR, run locally:
   ```bash
   flutter analyze
   flutter test
   ```
   These also run automatically in CI on every PR (see the `CI` badge on the README) — the sooner they're clean locally, the faster your PR can merge.
4. Commit messages: this project loosely follows [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:` prefixes) — not strictly enforced, but it makes the history easier to scan, so please follow the pattern where it fits.
5. Open a pull request against `main`, describing *what* changed and *why*. Link the issue it resolves, if any.

## Code style

- Standard Dart/Flutter conventions — the project uses `flutter_lints` (see `analysis_options.yaml`); `flutter analyze` will flag most style issues for you.
- Match the patterns already used in the file/screen you're editing rather than introducing a new pattern for the same problem — consistency matters more than any one person's preference.
- No enforced auto-formatting check in CI yet, but running `dart format .` on files you touch before committing is appreciated.

## License

By contributing, you agree that your contributions will be licensed under the project's [AGPL-3.0](LICENSE) license, same as the rest of the codebase.

## Questions?

Open an issue, or reach out at the contact address in the app's Settings → Credits screen. We're happy to help you get oriented.

---

Muruga Saranam 🙏 — and thank you for helping make this better for everyone who uses it.
