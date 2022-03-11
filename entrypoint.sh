#!/bin/bash

BASE="${INPUT_PATH:-.}"
POLICY="${INPUT_POLICY:-policy}"
FILES=( ${INPUT_FILES} )
MATCHES=( ${INPUT_MATCHES} )
NAMESPACE="${INPUT_NAMESPACE}"
ALL_NAMESPACES="${INPUT_ALL_NAMESPACES:-false}"

match() {
  local arg=${1}
  if [[ ${#MATCHES[@]} == 0 ]]; then
    return 0
  fi
  local match
  for match in ${MATCHES[@]}
  do
    if [[ ${arg} == ${match} ]]; then
      return 0
    fi
  done
  return 1
}

run_conftest() {
  local file

  local -a flags
  local -a files

  if [[ -n ${NAMESPACE} ]]; then
    flags+=(--namespace ${NAMESPACE})
  fi

  if ${ALL_NAMESPACES}; then
    flags+=(--all-namespaces)
  fi

  for file in "${FILES[@]}"
  do
    if ! match ${file}; then
      echo "[DEBUG] ${file}: against the matches condition, so skip it" >&2
      continue
    fi
    files+=("$file")

  done

  conftest test ${flags[@]} \
    --no-color \
    --policy "${POLICY}" \
    "${files[@]}"
}

main() {
  local -i status

  run_conftest "$@" | tee -a result
  status=${?}

  result="$(cat result)"
  # https://github.community/t5/GitHub-Actions/set-output-Truncates-Multiline-Strings/td-p/37870
  echo "::set-output name=result::${result//$'\n'/'%0A'}"

  return ${status}
}

set -o pipefail

main "$@"
exit $?
