#!/bin/bash
# Run lightweight syntax checks after Claude writes a file
FILE="$CLAUDE_TOOL_INPUT_FILE_PATH"
if [[ -z "$FILE" ]]; then exit 0; fi

case "$FILE" in
  *.yml|*.yaml)
    if command -v yamllint &>/dev/null; then
      yamllint -d relaxed "$FILE" 2>&1 | head -5
    fi
    ;;
  *.tf)
    if command -v terraform &>/dev/null; then
      cd "$(dirname "$FILE")" && terraform fmt -check "$FILE" 2>&1 | head -5
    fi
    ;;
esac
exit 0
