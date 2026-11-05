#!/usr/bin/env bash
# Installs the Azure DevOps work item rules for GitHub Copilot (macOS/Linux).
# Copies copilot-instructions.md to ~/.copilot/ (backing up any existing file).
# Never writes MCP config files: it prints the snippet to merge and where.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COPILOT_DIR="${COPILOT_HOME:-$HOME/.copilot}"

for f in copilot-instructions.md ado-work-items.instructions.md vscode-user-mcp.json copilot-cli-mcp-config.json; do
  if [[ ! -f "$SCRIPT_DIR/$f" ]]; then
    echo "Missing $f next to this script. Run it from docs/ado-copilot/." >&2
    exit 1
  fi
done

read -r -p "Azure DevOps organization name (from https://dev.azure.com/<org>): " ORG
ORG="${ORG// /}"
if [[ ! "$ORG" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  echo "Invalid organization name: '$ORG'" >&2
  exit 1
fi

# 1. Copilot CLI instructions
mkdir -p "$COPILOT_DIR"
TARGET="$COPILOT_DIR/copilot-instructions.md"
if [[ -f "$TARGET" ]] && cmp -s "$SCRIPT_DIR/copilot-instructions.md" "$TARGET"; then
  echo "Instructions already up to date: $TARGET"
else
  if [[ -e "$TARGET" ]]; then
    BACKUP="$TARGET.bak"
    if [[ -e "$BACKUP" ]]; then
      BACKUP="$TARGET.$(date +%Y%m%d%H%M%S).bak"
    fi
    cp -p "$TARGET" "$BACKUP"
    echo "Backed up existing instructions to: $BACKUP"
  fi
  cp "$SCRIPT_DIR/copilot-instructions.md" "$TARGET"
  echo "Installed instructions: $TARGET"
fi

# 2. MCP config (print only)
if [[ "$(uname -s)" == "Darwin" ]]; then
  VSCODE_MCP="$HOME/Library/Application Support/Code/User/mcp.json"
else
  VSCODE_MCP="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/mcp.json"
fi
CLI_MCP="$COPILOT_DIR/mcp-config.json"

echo
echo "=== VS Code MCP (not written) ==="
echo "Run \"MCP: Open User Configuration\" and merge this under the \"servers\" key."
echo "Default path: $VSCODE_MCP"
sed "s/YOUR_ORG/$ORG/g" "$SCRIPT_DIR/vscode-user-mcp.json"

echo
echo "=== Copilot CLI MCP (not written) ==="
echo "Merge this under the \"mcpServers\" key in: $CLI_MCP"
sed "s/YOUR_ORG/$ORG/g" "$SCRIPT_DIR/copilot-cli-mcp-config.json"
echo
echo "Or run instead:"
echo "  copilot mcp add --transport http ado-remote-mcp https://mcp.dev.azure.com/$ORG"

echo
echo "=== VS Code instructions (manual) ==="
echo "Run \"Chat: New Instructions File\", choose User, and paste the contents of:"
echo "  $SCRIPT_DIR/ado-work-items.instructions.md"

echo
echo "Sign in with your work Entra account when prompted."
