# Devbox provides support tools; languages are installed by the developer

Devbox pins support tools (just, terraform, tflint, copier, Postgres) per project. Go, Rust and
Node are installed by the developer (Go toolchain, rustup, fnm) because JetBrains IDEs work
poorly with Devbox-provided language runtimes. Language versions are still pinned in the repo
with the files every manager, IDE and CI action reads: `go.mod` (`go`/`toolchain`),
`rust-toolchain.toml`, `.node-version`, and `packageManager` in `package.json`. Go tools (sqlc,
goose, oapi-codegen, golangci-lint) are pinned with the `tool` directive in `go.mod`.
`just doctor` reports version mismatches.
