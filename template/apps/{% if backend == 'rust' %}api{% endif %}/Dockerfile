# syntax=docker/dockerfile:1
FROM rust:1.98-slim AS build
WORKDIR /src
COPY . .
ARG VERSION=dev
ENV API_VERSION=${VERSION}
RUN cargo build --release --locked && cp target/release/api /api

FROM gcr.io/distroless/cc-debian12:nonroot
COPY --from=build /api /api
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/api"]
CMD ["serve"]
