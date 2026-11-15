# apps/api (Go)

- HTTP handlers implement the generated `StrictServerInterface` (`internal/httpapi/api.gen.go`).
  Change the contract in `contract/` first, then `just generate`; never edit generated files.
- SQL lives in `internal/db/queries/*.sql` and is compiled by sqlc into `internal/db/sqlc`.
- Migrations are goose files in `migrations/`, created with `just new-migration <name>`, embedded
  in the binary and applied at startup. Never edit a migration that has been merged.
- Dev tools run through `go tool -modfile=tools.mod <tool>`; do not install them globally.
- Integration tests use a real Postgres via `TEST_DATABASE_URL` (`just test-api` sets it).
