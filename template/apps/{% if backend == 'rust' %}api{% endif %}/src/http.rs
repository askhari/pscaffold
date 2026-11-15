//! Routes and handlers. Types mirror `contract/schemas`.

use std::time::Duration;

use axum::extract::State;
use axum::http::{StatusCode, header};
use axum::response::{IntoResponse, Response};
use axum::routing::get;
use axum::{Json, Router};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use tower_http::catch_panic::CatchPanicLayer;
use tower_http::request_id::{MakeRequestUuid, PropagateRequestIdLayer, SetRequestIdLayer};
use tower_http::timeout::TimeoutLayer;
use tower_http::trace::TraceLayer;

/// Shared state for handlers.
#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub version: String,
}

/// `#/components/schemas/Health`
#[derive(Debug, Serialize, Deserialize, PartialEq, Eq)]
pub struct Health {
    pub status: String,
    pub database: String,
    pub version: String,
}

/// `#/components/schemas/Problem` (RFC 9457).
#[derive(Debug, Serialize, Deserialize)]
pub struct Problem {
    pub title: String,
    pub status: u16,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub detail: Option<String>,
}

impl IntoResponse for Problem {
    fn into_response(self) -> Response {
        let status = StatusCode::from_u16(self.status).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR);
        let mut response = (status, Json(self)).into_response();
        response.headers_mut().insert(
            header::CONTENT_TYPE,
            "application/problem+json".parse().expect("static header"),
        );
        response
    }
}

/// Builds the router with middleware.
pub fn router(state: AppState) -> Router {
    Router::new()
        .route("/healthz", get(get_health))
        .with_state(state)
        .layer(TraceLayer::new_for_http())
        .layer(TimeoutLayer::with_status_code(
            StatusCode::REQUEST_TIMEOUT,
            Duration::from_secs(30),
        ))
        .layer(CatchPanicLayer::new())
        .layer(PropagateRequestIdLayer::x_request_id())
        .layer(SetRequestIdLayer::x_request_id(MakeRequestUuid))
}

/// `GET /healthz` — liveness and database readiness.
async fn get_health(State(state): State<AppState>) -> Result<Json<Health>, Problem> {
    let ping = tokio::time::timeout(
        Duration::from_secs(2),
        sqlx::query_scalar::<_, i32>("SELECT 1").fetch_one(&state.pool),
    )
    .await;

    match ping {
        Ok(Ok(_)) => Ok(Json(Health {
            status: "ok".into(),
            database: "ok".into(),
            version: state.version.clone(),
        })),
        Ok(Err(err)) => {
            tracing::warn!(error = %err, "health: database unreachable");
            Err(unavailable())
        }
        Err(_) => {
            tracing::warn!("health: database timed out");
            Err(unavailable())
        }
    }
}

fn unavailable() -> Problem {
    Problem {
        title: "database unreachable".into(),
        status: 503,
        detail: None,
    }
}
