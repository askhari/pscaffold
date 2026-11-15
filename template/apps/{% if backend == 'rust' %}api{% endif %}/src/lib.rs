//! HTTP API implementing `contract/openapi.yaml`.
//!
//! Request and response types mirror the contract's schemas; the shared contract test suite
//! (`packages/api-client/contract-tests`) verifies the implementation against it.

pub mod config;
pub mod db;
pub mod http;
