# Authentication lives inside the API

Email + password (argon2id) and social login (Google, Microsoft, Apple) are implemented in an
isolated `auth` module of the API: clients obtain the provider's ID token, the API verifies it
against the provider's JWKS, and issues its own short-lived access token plus a rotating
refresh token stored hashed. A self-hosted IdP (Keycloak, Zitadel) costs more to operate on a
small VPS than the code it saves. We own rate limiting, email verification, password reset and
account linking; the module boundary keeps a later move to an external OIDC provider cheap.
Apple requires Sign in with Apple (or an equivalent) whenever other social logins are offered.
