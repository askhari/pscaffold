// Package migrations embeds the goose SQL migrations.
//
// Create a migration with `just new-migration <name>` (timestamped, so parallel branches never
// collide on a number).
package migrations

import "embed"

// FS holds every *.sql migration.
//
//go:embed *.sql
var FS embed.FS
