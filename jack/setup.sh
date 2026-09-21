#!/bin/sh
# jack global setup — runs inside every agent container on each fresh start,
# as root, via `sh` (dash) from the read-only config mount. Idempotent: every
# step checks what is already present at the pinned version and skips it.
#
# Two kinds of install live here:
#   - the persistent tools volume /root/.jack/bin: first on PATH, survives
#     container rebuilds, only `jack kill` removes it. Everything expensive
#     (gh, the Go SDK, linters, Go's module and build caches) goes here so it
#     is fetched once per agent-repo rather than once per container.
#   - per-container apt packages: cheap, reinstalled on every fresh container.
#
# Every agent works in Go, so the toolchain is global rather than per-project.
# The pins below are the source of truth; keep them in sync with the repos:
#   Go            -> the highest `toolchain` line across the repos' go.mod.
#                    Older pins are satisfied by a newer 1.x; a newer pin makes
#                    go fetch that toolchain itself into the persisted mod cache.
#   golangci-lint -> Makefile `install-tools` / .github/workflows/ci.yml
#   gosec         -> .github/workflows/ci.yml
#   air           -> Makefile `install-tools` (latest; resolved at install time)
set -eu

GO_VERSION="1.25.5"
GOLANGCI_LINT_VERSION="2.7.2"
GOSEC_VERSION="2.22.11"
AIR_VERSION="latest"

BIN="/root/.jack/bin"
GO_HOME="$BIN/.go"      # SDK + caches; hidden so `ls $BIN` stays tools-only
GO_ROOT="$GO_HOME/root"
GO_MODCACHE="$GO_HOME/mod"
GO_CACHE="$GO_HOME/cache"

step() { printf '==> %s\n' "$*"; }
ok()   { printf '  ok %s\n' "$*"; }

# amd64 | arm64 — matches the asset naming of every release fetched below.
ARCH="$(dpkg --print-architecture)"

# Downloads extract into a scratch dir and are moved into place only once
# complete, so a broken download never leaves a truncated tool on the volume.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------------------
# apt — per container. make drives every repo's Makefile; gcc + libc headers
# are cgo, which `go test -race` requires ("-race requires cgo" otherwise).
# ---------------------------------------------------------------------------
step "apt: make gcc"
if command -v make >/dev/null 2>&1 && command -v gcc >/dev/null 2>&1; then
  ok "present"
else
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq --no-install-recommends make gcc libc6-dev >/dev/null
  rm -rf /var/lib/apt/lists/*
  ok "installed"
fi

# ---------------------------------------------------------------------------
# gh — latest release, installed once into the volume.
# ---------------------------------------------------------------------------
step "gh"
if [ -x "$BIN/gh" ]; then
  ok "present ($("$BIN/gh" --version | head -1))"
else
  ver="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
    | grep -o '"tag_name": *"v[^"]*"' | cut -d'"' -f4)"
  ver="${ver#v}"
  curl -fsSL "https://github.com/cli/cli/releases/download/v${ver}/gh_${ver}_linux_${ARCH}.tar.gz" \
    | tar -xz -C "$TMP" --strip-components=2 "gh_${ver}_linux_${ARCH}/bin/gh"
  mv "$TMP/gh" "$BIN/gh"
  ok "installed gh ${ver}"
fi

# Route git's HTTPS credentials through gh. GH_TOKEN arrives in the container
# env from ~/.jack/secrets/<agent>.env on the host; with it set, both gh and
# `git push` authenticate as this agent with no login step. Per container:
# this writes ~/.gitconfig, which does not persist.
if [ -n "${GH_TOKEN:-}" ]; then
  gh auth setup-git
fi

# ---------------------------------------------------------------------------
# Go SDK — installed once into the volume, exposed on PATH via symlinks.
# go resolves GOROOT from the real path of its binary, so the symlinks need
# no GOROOT setting.
# ---------------------------------------------------------------------------
step "go ${GO_VERSION}"
if [ "$("$GO_ROOT/bin/go" version 2>/dev/null | awk '{print $3}')" = "go${GO_VERSION}" ]; then
  ok "present"
else
  curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -xz -C "$TMP"
  mkdir -p "$GO_HOME"
  rm -rf "$GO_ROOT"
  mv "$TMP/go" "$GO_ROOT"
  ok "installed"
fi
ln -sfn "$GO_ROOT/bin/go" "$BIN/go"
ln -sfn "$GO_ROOT/bin/gofmt" "$BIN/gofmt"

# Per container: go's own env file (~/.config/go/env) is read by every go
# invocation regardless of shell, so no profile.d or rc-file plumbing is
# needed for claude's shells to see this.
#   GOBIN      -> `go install` (e.g. a repo's `make install-tools`) lands on PATH
#   GOMODCACHE -> downloaded modules and auto-fetched newer toolchains persist
#   GOCACHE    -> build/test cache persists, so a rebuilt container tests warm
go env -w GOBIN="$BIN" GOMODCACHE="$GO_MODCACHE" GOCACHE="$GO_CACHE"

# ---------------------------------------------------------------------------
# Go tooling — prebuilt release binaries into the volume (seconds, vs minutes
# for `go install` compiling golangci-lint) and they report a real version,
# which a `go install` build of gosec does not ("dev").
# ---------------------------------------------------------------------------
step "golangci-lint ${GOLANGCI_LINT_VERSION}"
if "$BIN/golangci-lint" version 2>/dev/null | grep -q "version ${GOLANGCI_LINT_VERSION} "; then
  ok "present"
else
  name="golangci-lint-${GOLANGCI_LINT_VERSION}-linux-${ARCH}"
  curl -fsSL "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/${name}.tar.gz" \
    | tar -xz -C "$TMP" --strip-components=1 "${name}/golangci-lint"
  mv "$TMP/golangci-lint" "$BIN/golangci-lint"
  ok "installed"
fi

step "gosec ${GOSEC_VERSION}"
if "$BIN/gosec" --version 2>/dev/null | grep -q "^Version: ${GOSEC_VERSION}$"; then
  ok "present"
else
  curl -fsSL "https://github.com/securego/gosec/releases/download/v${GOSEC_VERSION}/gosec_${GOSEC_VERSION}_linux_${ARCH}.tar.gz" \
    | tar -xz -C "$TMP" gosec
  mv "$TMP/gosec" "$BIN/gosec"
  ok "installed"
fi

step "air (${AIR_VERSION})"
if [ -x "$BIN/air" ]; then
  ok "present"
else
  # Prebuilt rather than `go install`: air@latest already requires a newer Go
  # than the pin, so a source build would pull a second toolchain to do it.
  ver="$AIR_VERSION"
  if [ "$ver" = "latest" ]; then
    ver="$(curl -fsSL https://api.github.com/repos/air-verse/air/releases/latest \
      | grep -o '"tag_name": *"v[^"]*"' | cut -d'"' -f4)"
  fi
  ver="${ver#v}"
  curl -fsSL "https://github.com/air-verse/air/releases/download/v${ver}/air_${ver}_linux_${ARCH}" -o "$TMP/air"
  chmod +x "$TMP/air"
  mv "$TMP/air" "$BIN/air"
  ok "installed air ${ver}"
fi

printf '\ntoolchain ready: %s, golangci-lint %s, gosec %s, air %s, gh %s\n' \
  "$(go version | awk '{print $3}')" \
  "$(golangci-lint version | awk '{print $4}')" \
  "$(gosec --version | awk '/^Version:/{print $2}')" \
  "$(air -v 2>&1 | awk '/built with/{sub(",","",$1); print $1}')" \
  "$(gh --version | awk 'NR==1{print $3}')"
