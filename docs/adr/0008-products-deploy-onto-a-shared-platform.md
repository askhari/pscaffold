# Products deploy onto a shared platform

A generated product no longer creates or runs its own infrastructure. The first product showed
that a per-product stack (own Droplet through Terraform, own PostgreSQL and Caddy bound to
ports 80/443) cannot share a machine and costs a machine per product. Products now deploy one
API container onto a shared platform kept in its own repository: one host with Docker Compose,
one PostgreSQL server, one Caddy, per-product buckets. The template only knows the platform's
interface: the directory `/opt/platform/products/<product>-<env>/` with a `db.env` holding
`DATABASE_URL`, the external Docker network `platform`, the container name
`<product>-<env>-api` that Caddy proxies to, and SSH as `deploy`. `platform_product` is asked
at generation time (default: the slug without dashes) because the platform's names must be
valid PostgreSQL identifiers.

Considered options: keeping a standalone variant behind `infra_target` — rejected, it is a
second deployment shape to test and nobody uses it. Deriving the platform name without a
question — rejected, a tenant that already exists under another name could not be matched.

PostgreSQL stays on one major (18) across the platform, local Devbox and CI; local databases
use a port derived from the product slug so several products run side by side.
