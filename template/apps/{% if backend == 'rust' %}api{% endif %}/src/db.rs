//! Database pool and migrations (sqlx, embedded in the binary).

use anyhow::{Context, Result};
use sqlx::PgPool;
use sqlx::postgres::PgPoolOptions;

/// Connects to Postgres.
pub async fn connect(database_url: &str) -> Result<PgPool> {
    PgPoolOptions::new()
        .max_connections(10)
        .connect(database_url)
        .await
        .context("connect database")
}

/// Applies every pending migration from `migrations/`.
///
/// Create a migration with `just new-migration <name>` (timestamped, so parallel branches never
/// collide on a number).
pub async fn migrate(pool: &PgPool) -> Result<()> {
    sqlx::migrate!("./migrations")
        .run(pool)
        .await
        .context("apply migrations")
}
