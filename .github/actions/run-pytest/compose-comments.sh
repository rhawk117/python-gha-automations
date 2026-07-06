#!/usr/bin/env bash


# expected env inputs:
#   OUTCOME         pytest step outcome (success|failure)
#   SUCCESS_MARKER  marker slug for the success comment ('' disables it)
#   FAILURE_MARKER  marker slug for the failure comment
#   ARTIFACT_URL    coverage artifact URL
#   RUN_URL         link to the run logs

set -euo pipefail

coverage_gate_comment() {
  printf '%s\n' "### :x: Coverage gate not met"
  printf '\n'
  printf '%s\n' "Tests passed, but coverage is below the required threshold:"
  printf '\n'
  printf '%s\n' '```text'
  grep -E '^(TOTAL|FAIL Required test coverage)' pytest-output.txt
  printf '%s\n' '```'
  printf '\n'
  printf '%s\n' "Per-file breakdown: [coverage artifact](${ARTIFACT_URL})"
}

suite_failed_comment() {
  printf '%s\n' "### :x: Test suite failed"
  printf '\n'
  printf '%s\n' '```text'
  if grep -q '^=* FAILURES' pytest-output.txt 2>/dev/null; then
    awk '/^=+ FAILURES/{found=1} found' pytest-output.txt | tail -c 60000
  else
    tail -n 60 pytest-output.txt
  fi
  printf '%s\n' '```'
}

failure_comment() {
  if grep -q 'FAIL Required test coverage' pytest-output.txt 2>/dev/null; then
    coverage_gate_comment
  else
    suite_failed_comment
  fi
  printf '\n'
  printf '%s\n' "[Run logs](${RUN_URL})"
}

success_comment() {
  printf '%s\n' "### :white_check_mark: Tests passed"
  printf '\n'
  printf '%s\n' "Coverage report: [download artifact](${ARTIFACT_URL})"
  printf '%s\n' "(run [logs](${RUN_URL}))"
  printf '\n'
  printf '%s\n' "**Next step:** add the \`auto-qa\` label to run the integration suite — required before this PR can merge."
}

post=false
marker=

if [[ "$OUTCOME" == "failure" ]]; then
  marker="$FAILURE_MARKER"
  post=true
  failure_comment > COMMENT.md
elif [[ "$OUTCOME" == "success" && -n "$SUCCESS_MARKER" ]]; then
  marker="$SUCCESS_MARKER"
  post=true
  success_comment > COMMENT.md
fi

{
  echo "post=$post"
  echo "marker=$marker"
} >> "$GITHUB_OUTPUT"
