# iii-engine v0.11.2 - Production Image (distroless runtime)
# Optimized for GitHub Actions builders with memory constraints
# Build: docker build -t iiidev/iii:0.11.2 .

FROM rust:1.81-slim AS builder

WORKDIR /build

# Install build dependencies and clean cache
RUN apt-get update && apt-get install -y \
    git \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone iii-hq/iii v0.11.2
RUN git clone --depth 1 --branch iii/v0.11.2 https://github.com/iii-hq/iii.git .

WORKDIR /build/engine

# Reduce memory usage during build
# Set cargo parallel jobs and incremental compilation
ENV CARGO_BUILD_JOBS=2
ENV CARGO_INCREMENTAL=0
ENV RUSTFLAGS="-C link-arg=-fuse-ld=lld -C target-cpu=generic"

# Build release binary with optimizations for smaller binary
RUN cargo build --release \
    -j 2 \
    --profile release \
    && cargo clean

# Production image - distroless (no shell, minimal attack surface)
FROM gcr.io/distroless/cc-debian12:nonroot

WORKDIR /app

# Copy the compiled binary from builder
COPY --from=builder /build/engine/target/release/iii /app/iii

# Copy default config (fallback if not found, continue silently)
COPY --from=builder /build/engine/iii-config.yaml /app/iii-config.yaml 2>/dev/null || true

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
