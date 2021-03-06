#!/usr/bin/env bash

set -euo pipefail

readonly LOCAL_PERSIST_VERSION="1.3.0"
readonly cmd="local-persist"
readonly arch=$(uname -m)

# local_persist::check_version checks the command and the version.
local_persist::check_version() {
  local has_installed

  has_installed="$(command -v local-persist || echo false)"
  if [[ "${has_installed}" = "false" ]]; then
    echo false
    exit 0
  fi
  echo true
}

# local_persist::install downloads the binary from release url.
local_persist::install() {
  local url target

  target="/tmp/${cmd}"
  url="https://github.com/CWSpear/local-persist/releases/download"
  if [[ "${arch}" == "aarch64" ]]; then
    git clone https://github.com/MatchbookLab/local-persist/
    cd local-persist/
    curl https://glide.sh/get | sh
    glide install
    go build -o /usr/bin/local-persist
    cd ..
    rm -rf local-persist/
  else
    url="${url}/v${LOCAL_PERSIST_VERSION}/local-persist-linux-amd64"
    wget --quiet -O "${target}" "${url}"
    chmod +x "${target}"
    mv "${target}" /usr/bin/
  fi
}

main() {
  local has_installed

  has_installed="$(local_persist::check_version)"
  if [[ "${has_installed}" = "true" ]]; then
    echo "${cmd}-${LOCAL_PERSIST_VERSION} has been installed."
    exit 0
  fi

  echo ">>>> install ${cmd}-${LOCAL_PERSIST_VERSION} <<<<"

  local_persist::install

  # final check
  command -v "${cmd}" > /dev/null

  echo
}

main
