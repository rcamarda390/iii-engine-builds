# iii-engine v0.11.2 - Production Image (distroless runtime)
# Uses pre-built binary from GitHub releases
# Build: docker build -t iiidev/iii:0.11.2 .

FROM curlimages/curl:latest AS downloader

WORKDIR /tmp

# Download and extract pre-built iii-engine v0.11.2 binary
RUN curl -fsSL -o iii.tar.gz \
    https://github.com/iii-hq/iii/releases/download/iii/v0.11.2/iii-x86_64-unknown-linux-gnu.tar.gz && \
    tar -xzf iii.tar.gz && \
    ls -lh iii && \
    chmod +x iii

# Production image - distroless (no shell, minimal attack surface)
FROM gcr.io/distroless/cc-debian12:nonroot

WORKDIR /app

# Copy pre-built binary from downloader stage
COPY --from=downloader /tmp/iii /app/iii

# NO RUN COMMANDS in distroless final stage!
# Distroless has no shell, so RUN fails

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
