//! Runtime configuration from environment variables.

use anyhow::{Context, Result, bail};

/// The API's runtime configuration.
#[derive(Debug, Clone)]
pub struct Config {
    pub database_url: String,
    pub port: u16,
}

impl Config {
    /// Reads the configuration from the process environment.
    pub fn from_env() -> Result<Self> {
        Self::from_lookup(|key| std::env::var(key).ok())
    }

    /// Reads the configuration through `lookup`, which makes it testable without touching the
    /// process environment.
    pub fn from_lookup(lookup: impl Fn(&str) -> Option<String>) -> Result<Self> {
        let database_url = lookup("DATABASE_URL").unwrap_or_default();
        if database_url.trim().is_empty() {
            bail!("DATABASE_URL is required");
        }
        let port = match lookup("API_PORT").filter(|v| !v.is_empty()) {
            Some(v) => v
                .parse()
                .with_context(|| format!("API_PORT must be a port number, got {v:?}"))?,
            None => 8080,
        };
        Ok(Self { database_url, port })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn lookup<'a>(pairs: &'a [(&'a str, &'a str)]) -> impl Fn(&str) -> Option<String> + 'a {
        move |key| {
            pairs
                .iter()
                .find(|(k, _)| *k == key)
                .map(|(_, v)| (*v).to_string())
        }
    }

    #[test]
    fn defaults_port() {
        let cfg = Config::from_lookup(lookup(&[("DATABASE_URL", "postgres://localhost/app")])).unwrap();
        assert_eq!(cfg.port, 8080);
    }

    #[test]
    fn requires_database_url() {
        assert!(Config::from_lookup(lookup(&[("DATABASE_URL", "")])).is_err());
    }

    #[test]
    fn rejects_invalid_port() {
        let err = Config::from_lookup(lookup(&[("DATABASE_URL", "postgres://x"), ("API_PORT", "http")]));
        assert!(err.is_err());
    }
}
