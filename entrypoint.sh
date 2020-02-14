#!/bin/bash

BASE="${INPUT_PATH:-.}"
EXTS=( ${INPUT_EXTENSIONS} )
POLICY="${INPUT_POLICY:-policy}"
FILES=( ${INPUT_FILES} )

{
  echo "[DEBUG] files: ${FILES[@]}"
  echo "[DEBUG] extensions: ${EXTS[@]}"
  echo "[DEBUG] policy: ${POLICY}"
  echo "[DEBUG] base directory: ${BASE}"
} >&2

run_conftest() {
  local file ext
  local error=false

  for ext in ${EXTS[@]}
  do
    for file in ${BASE}/*.${ext}
    do
      conftest test \
        --no-color \
        --policy "${POLICY}" \
        --input "${ext}" "${file}" || error=true
    done
  done

  for file in "${FILES[@]}"
  do
    ext="${file##*.}"
    conftest test \
      --no-color \
      --policy "${POLICY}" \
      --input "${ext}" "${file}" || error=true
  done

  if ${error}; then
    return 1
  fi
}

main() {
  run_conftest "$@" | tee -a result
  result="$(cat result)"
  # https://github.community/t5/GitHub-Actions/set-output-Truncates-Multiline-Strings/td-p/37870
  echo "::set-output name=result::${result//$'\n'/'%0A'}"
}

set -o pipefail

main "$@"
exit $?
