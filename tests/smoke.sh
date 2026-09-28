#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
    echo "Usage: sh tests/smoke.sh IMAGE frpc|frps VERSION" >&2
    exit 1
fi

image=$1
target=$2
version=$3
case "$target" in
    frpc|frps) ;;
    *) echo "Target must be frpc or frps" >&2; exit 1 ;;
esac

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
actual=$(docker run --rm "$image" --version)
test "$actual" = "$version"
docker run --rm "$image" --help | grep -Eq "^[[:space:]]+${target}( |$)"
docker run --rm \
    --mount "type=bind,src=${root}/config/${target}.toml.example,dst=/etc/frp/frp.toml,readonly" \
    "$image" verify -c /etc/frp/frp.toml

# The empty config path must fail, rather than silently starting with defaults.
if docker run --rm "$image" verify -c /etc/frp/missing.toml; then
    echo "Missing configuration unexpectedly passed verification" >&2
    exit 1
fi
