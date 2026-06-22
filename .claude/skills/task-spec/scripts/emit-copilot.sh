#!/usr/bin/env bash
# emit-copilot.sh — Write the task-spec section into .github/copilot-instructions.md.
#
# Uses section markers so multiple skills can coexist in one file:
#   <!-- BEGIN:task-spec --> ... <!-- END:task-spec -->
#
# Inputs:
#   TARGET_REPO  absolute path to the target repo
#
# Exit codes:
#   0  emitted
#   1  TARGET_REPO unset or invalid

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SKILL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
TEMPLATE="${SKILL_ROOT}/templates/copilot-instructions.md.tpl"

if [[ -z "${TARGET_REPO:-}" ]]; then
  echo "ERROR: TARGET_REPO must be set (absolute path to the target repo)" >&2
  exit 1
fi

if [[ ! -d "${TARGET_REPO}" ]]; then
  echo "ERROR: TARGET_REPO does not exist: ${TARGET_REPO}" >&2
  exit 1
fi

if [[ ! -f "${TEMPLATE}" ]]; then
  echo "ERROR: template not found: ${TEMPLATE}" >&2
  exit 1
fi

GH_DIR="${TARGET_REPO}/.github"
COPILOT_MD="${GH_DIR}/copilot-instructions.md"
SECTION_CONTENT="$(cat "${TEMPLATE}")"

mkdir -p "${GH_DIR}"

python3 - "${COPILOT_MD}" "${SECTION_CONTENT}" <<'PYEOF'
import sys
from pathlib import Path

path = Path(sys.argv[1])
section = sys.argv[2]

BEGIN = "<!-- BEGIN:task-spec -->"
END   = "<!-- END:task-spec -->"

if path.exists():
    text = path.read_text()
else:
    text = ""

import re
pattern = re.compile(re.escape(BEGIN) + r".*?" + re.escape(END), re.DOTALL)

if pattern.search(text):
    new_text = pattern.sub(section, text)
else:
    sep = "\n\n" if text.strip() else ""
    new_text = text + sep + section + "\n"

path.write_text(new_text)
PYEOF

echo "✓ wrote task-spec section → ${COPILOT_MD}"
echo ""
echo "────────────────────────────────────────────────────────────────────────"
echo "Task-Spec Copilot instructions emitted."
echo "Re-emit after updating the task-spec skill or template."
echo "Run agents-kbs-tech-stack/scripts/emit-cross-tool.sh to merge the"
echo "agent-fleet section into the same file."
echo "────────────────────────────────────────────────────────────────────────"
