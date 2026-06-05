# iii-engine v0.11.2 - Production Image (distroless runtime)
# Build: docker build -t iiidev/iii:0.11.2 .
# Run: docker run -p 3111:3111 -p 49134:49134 iiidev/iii:0.11.2

FROM rust:1.81 AS builder

WORKDIR /build

# Clone iii-hq/iii v0.11.2
RUN git clone --depth 1 --branch iii/v0.11.2 https://github.com/iii-hq/iii.git .

WORKDIR /build/engine

# Build the binary
RUN cargo build --release

# Production image - distroless (no shell, minimal attack surface)
FROM gcr.io/distroless/cc-debian12:nonroot

WORKDIR /app

# Copy the compiled binary from builder
COPY --from=builder /build/engine/target/release/iii /app/iii

# Copy default config
COPY --from=builder /build/engine/iii-config.yaml /app/iii-config.yaml

# Default ports:
# 3111 - REST API
# 49134 - Worker WebSocket
# 3112 - Stream events
# 9464 - OpenTelemetry metrics
EXPOSE 3111 49134 3112 9464

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD ["/app/iii", "--version"]

ENTRYPOINT ["/app/iii"]
CMD ["--use-default-config"]
