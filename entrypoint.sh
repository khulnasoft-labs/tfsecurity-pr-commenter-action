#!/usr/bin/env bash

set -xe

if [ -z "${INPUT_GITHUB_TOKEN}" ] ; then
  echo "Consider setting a GITHUB_TOKEN to prevent GitHub api rate limits." >&2
fi

TFSECURITY_VERSION=""
if [ "$INPUT_TFSECURITY_VERSION" != "latest" ] && [ -n "$INPUT_TFSECURITY_VERSION" ]; then
  TFSECURITY_VERSION="/tags/${INPUT_TFSECURITY_VERSION}"
else
  TFSECURITY_VERSION="/latest"
fi

COMMENTER_VERSION="latest"
if [ "$INPUT_COMMENTER_VERSION" != "latest" ] && [ -n "$INPUT_COMMENTER_VERSION" ]; then
  COMMENTER_VERSION="/tags/${INPUT_COMMENTER_VERSION}"
else
  COMMENTER_VERSION="/latest"
fi

function get_release_assets {
  repo="$1"
  version="$2"
  args=(
    -sSL
    --header "Accept: application/vnd.github+json"
  )
  [ -n "${INPUT_GITHUB_TOKEN}" ] && args+=(--header "Authorization: Bearer ${INPUT_GITHUB_TOKEN}")
  curl "${args[@]}" "https://api.github.com/repos/$repo/releases${version}" | jq '.assets[] | { name: .name, download_url: .browser_download_url }'
}

function install_release {
  repo="$1"
  version="$2"
  binary="$3-linux-amd64"
  checksum="$4"
  release_assets="$(get_release_assets "${repo}" "${version}")"

  curl -sLo "${binary}" "$(echo "${release_assets}" | jq -r ". | select(.name == \"${binary}\") | .download_url")"
  curl -sLo "$3-checksums.txt" "$(echo "${release_assets}" | jq -r ". | select(.name | contains(\"$checksum\")) | .download_url")"

  grep "${binary}" "$3-checksums.txt" | sha256sum -c -
  install "${binary}" "/usr/local/bin/${3}"
}

install_release khulnasoft-labs/tfsecurity."${TFSECURITY_VERSION}" tfsecurity.tfsecurity.checksums.txt
install_release khulnasoft-labs/tfsecurity.rity-pr-commenter-action "${COMMENTER_VERSION}" commenter checksums.txt

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

if [ -n "${INPUT_TFSECURITY_ARGS}" ]; then
  TFSECURITY_ARGS_OPTION="${INPUT_TFSECURITY_ARGS}"
fi

TFSECURITY_FORMAT_OPTION="json"
TFSECURITY_OUT_OPTION="results.json"
if [ -n "${INPUT_TFSECURITY_FORMATS}" ]; then
  TFSECURITY_FORMAT_OPTION="${TFSECURITY_FORMAT_OPTION},${INPUT_TFSECURITY_FORMATS}"
  TFSECURITY_OUT_OPTION="${TFSECURITY_OUT_OPTION%.*}"
fi

tfsecurity.--out=${TFSECURITY_OUT_OPTION} --format="${TFSECURITY_FORMAT_OPTION}" --soft-fail ${TFSECURITY_ARGS_OPTION} "${INPUT_WORKING_DIRECTORY}"
commenter
