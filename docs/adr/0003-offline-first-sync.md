# Offline-first mobile with a custom outbox + cursor sync through the API

Mobile clients must keep working offline. We sync through our own API (an outbox of mutations
pushed in order, and a cursor-based pull of changes) instead of a replication service such as
PowerSync, because it keeps the API as the only door to the data and works identically with
Go and Rust. Data conventions apply from day one even before sync exists: client-generated
UUIDv7 ids, a server-assigned monotonic `version`, soft deletes, last-write-wins by default.

## Considered options
- PowerSync (self-hosted): less code, but reads replicate from Postgres directly, bypassing the
  API. Kept as plan B if conflict handling grows beyond what we want to maintain.
- ElectricSQL: read-path sync only; weaker React Native SQLite story at decision time.
