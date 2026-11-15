# apps/api (Rust)

- The contract in `contract/` is the source of truth. Request/response types in `src/http.rs`
  mirror its schemas by hand; `just test-contract` runs the shared contract suite against this
  server, so a mismatch fails verification. Change the contract first, then the types.
- Migrations are sqlx reversible pairs in `migrations/`, created with `just new-migration <name>`,
  embedded with `sqlx::migrate!` and applied at startup. Never edit a merged migration.
- Prefer runtime-checked `sqlx::query_as` until the project adopts `cargo sqlx prepare`
  (compile-time checked macros need the `.sqlx/` offline data committed).
- Integration tests use a real Postgres via `TEST_DATABASE_URL` (`just test-api` sets it).
