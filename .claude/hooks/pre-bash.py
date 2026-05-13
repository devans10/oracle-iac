#!/usr/bin/env python3
"""Block commands that could accidentally affect production systems."""
import json, sys, re

data = json.loads(sys.stdin.read())
cmd = data.get("tool_input", {}).get("command", "")

BLOCKED = [
    r'\bansible-playbook\b.*\binventories/production\b',
    r'\bterraform\s+(apply|destroy)\b(?!.*-auto-approve)',
    r'\brm\s+-rf\s+/',
    r'\bdd\b.*\bof=/dev/',
]

for pattern in BLOCKED:
    if re.search(pattern, cmd, re.IGNORECASE):
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "block",
                "permissionDecisionReason": f"Blocked by pre-bash hook: matches safety pattern '{pattern}'"
            }
        }))
        sys.exit(0)

sys.exit(0)
