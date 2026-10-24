# Thiruppugazh app: working agreements

## Confirm before changing code

Make intentional changes only. Before editing, creating, or deleting any code
(anything under `lib/`, `test/`, `assets/`, `android/`, `scripts/`, `pubspec.yaml`, DB
schema or migrations):

1. State what you plan to change: the behavior, the files involved, and any schema,
   dependency, or backup-format impact.
2. Wait for the user's explicit go-ahead.

Reading, searching, and discussing options do not need confirmation. A go-ahead covers
only the plan that was described; if the scope grows mid-task, confirm again.

## Branches and releases

- `main` is stable and always matches what is published on the store.
- New features land on `next` first.
- Cycle: build on `next`, publish, let it soak for a period, then merge `next` into `main`
  and tag the release (`vX.Y.Z`).
- `v2-features` is a parked tangent. Bring features over from it one at a time by
  cherry-picking onto `next` and adapting them; do not merge the branch.
