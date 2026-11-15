//! `api serve` (default) runs migrations and serves HTTP; `api migrate` only runs migrations.

use anyhow::{Result, bail};
use api::{config::Config, db, http};
use tokio::net::TcpListener;
use tracing_subscriber::EnvFilter;

/// Build version, set with `API_VERSION` at compile time (`--build-arg VERSION` in Docker).
const VERSION: &str = match option_env!("API_VERSION") {
    Some(v) => v,
    None => "dev",
};

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .json()
        .with_env_filter(EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")))
        .init();

    let cfg = Config::from_env()?;
    let pool = db::connect(&cfg.database_url).await?;
    db::migrate(&pool).await?;

    match std::env::args().nth(1).as_deref().unwrap_or("serve") {
        "migrate" => Ok(()),
        "serve" => serve(cfg, pool).await,
        other => bail!("unknown command {other:?} (want serve or migrate)"),
    }
}

async fn serve(cfg: Config, pool: sqlx::PgPool) -> Result<()> {
    let app = http::router(http::AppState {
        pool,
        version: VERSION.to_string(),
    });
    let listener = TcpListener::bind(("0.0.0.0", cfg.port)).await?;
    tracing::info!(addr = %listener.local_addr()?, version = VERSION, "listening");
    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal())
        .await?;
    Ok(())
}

async fn shutdown_signal() {
    let ctrl_c = async {
        let _ = tokio::signal::ctrl_c().await;
    };
    #[cfg(unix)]
    let terminate = async {
        if let Ok(mut s) = tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate()) {
            s.recv().await;
        }
    };
    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();
    tokio::select! {
        () = ctrl_c => {},
        () = terminate => {},
    }
}
