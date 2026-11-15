# apps/app

Expo SDK changes every release: before using an Expo, EAS or React Native API, read the
versioned docs for the `expo` major in `package.json` (`https://docs.expo.dev/versions/v<major>.0.0/`)
or `https://docs.expo.dev/llms.txt`. Do not rely on memory.

- Add dependencies with `pnpm expo install <pkg>` so versions match the SDK.
- Routes live in `src/app/` (Expo Router); non-route code lives in `src/` outside `app/`.
- `ios/` and `android/` are generated (CNG); never edit them — use `app.config.ts` and config plugins.
- Talk to the backend only through `@/lib/api` (generated from `contract/`). Never hand-write
  request or response types.
- Offline-first: data the user edits goes to local SQLite first and syncs through the API
  (see the sync ADR and spec). Do not call the API directly from screens for synced entities.
