# syntax=docker/dockerfile:1

ARG FRP_VERSION
ARG TARGET=frps

FROM --platform=$BUILDPLATFORM alpine:3.22 AS builder

ARG FRP_VERSION
ARG TARGET
ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl jq tar

WORKDIR /tmp

RUN set -eux; \
    case "${TARGET}" in \
      frps|frpc) ;; \
      *) echo "TARGET must be frps or frpc"; exit 1 ;; \
    esac; \
    case "${TARGETARCH}" in \
      amd64|arm64) ;; \
      *) echo "Supported architectures: amd64, arm64"; exit 1 ;; \
    esac; \
    if [ -z "${FRP_VERSION:-}" ]; then \
      curl -fL --retry 3 --connect-timeout 15 --max-time 60 \
        https://api.github.com/repos/fatedier/frp/releases/latest -o release.json; \
      FRP_VERSION="$(jq -er '.tag_name | select(type == "string") | sub("^v"; "")' release.json)"; \
    fi; \
    printf '%s\n' "${FRP_VERSION}" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; \
    archive="frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    release="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}"; \
    curl -fL --retry 3 --connect-timeout 15 --max-time 180 "${release}/${archive}" -o "${archive}"; \
    curl -fL --retry 3 --connect-timeout 15 --max-time 60 "${release}/frp_sha256_checksums.txt" -o checksums.txt; \
    awk -v file="${archive}" '$2 == file {print}' checksums.txt > checksum.txt; \
    test -s checksum.txt; \
    sha256sum -c checksum.txt; \
    tar -xzf "${archive}"; \
    cp "frp_${FRP_VERSION}_linux_${TARGETARCH}/${TARGET}" /usr/local/bin/frp; \
    cp "frp_${FRP_VERSION}_linux_${TARGETARCH}/LICENSE" /tmp/LICENSE; \
    chmod +x /usr/local/bin/frp

FROM alpine:3.22

ARG TARGET

LABEL org.opencontainers.image.title="${TARGET}" \
      org.opencontainers.image.source="https://github.com/ljwtorch/frp-docker" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN apk add --no-cache ca-certificates tzdata \
    && mkdir -p /etc/frp

COPY --from=builder /usr/local/bin/frp /usr/local/bin/frp
COPY --from=builder /tmp/LICENSE /usr/share/licenses/frp/LICENSE

ENV TZ=Asia/Shanghai

WORKDIR /etc/frp

ENTRYPOINT ["/usr/local/bin/frp"]
CMD ["-c", "/etc/frp/frp.toml"]
