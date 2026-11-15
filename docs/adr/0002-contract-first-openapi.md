# The OpenAPI contract is the source of truth

`contract/openapi.yaml` defines the API; the TypeScript client and the Go server interface are
generated from it and CI fails when generated code drifts. This keeps clients and backend
independent (the backend language can change), turns the API into the seam between parallel
agents, and lets one contract test suite verify both the Go and the Rust implementations.
The contract is split into one file per resource to avoid merge conflicts between agents.
