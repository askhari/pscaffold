//! Integration test against a real Postgres (`TEST_DATABASE_URL`, set by `just test-api`).

use api::{db, http};
use axum::body::Body;
use axum::http::{Request, StatusCode};
use http_body_util::BodyExt;
use tower::ServiceExt;

#[tokio::test]
async fn health_reports_ok() {
    let Ok(url) = std::env::var("TEST_DATABASE_URL") else {
        eprintln!("TEST_DATABASE_URL not set; run through `just test-api`");
        return;
    };
    let pool = db::connect(&url).await.expect("connect");
    db::migrate(&pool).await.expect("migrate");
    let app = http::router(http::AppState {
        pool,
        version: "test".into(),
    });

    let response = app
        .oneshot(Request::get("/healthz").body(Body::empty()).unwrap())
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
    let body = response.into_body().collect().await.unwrap().to_bytes();
    let health: http::Health = serde_json::from_slice(&body).unwrap();
    assert_eq!(
        health,
        http::Health {
            status: "ok".into(),
            database: "ok".into(),
            version: "test".into()
        }
    );
}
