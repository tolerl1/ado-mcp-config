# Azure DevOps work item rules for GitHub Copilot

User-level setup so GitHub Copilot (CLI and VS Code) creates Azure DevOps Features, PBIs, and Tasks the same way, through the remote Azure DevOps MCP server.

Replace `YOUR_ORG` with your Azure DevOps organization name in the MCP files before installing them.

## Files

| File | What it is | Install to (user level) |
|---|---|---|
| `copilot-instructions.md` | The rules, no frontmatter | `~/.copilot/copilot-instructions.md` |
| `mcp-config.json` | ADO MCP server, portable Copilot format (`mcpServers`) | `~/.copilot/mcp-config.json` |
| `ado-work-items.instructions.md` | Same rules with frontmatter (`applyTo: "**"`) | VS Code user profile (Local harness only, see below) |
| `vscode-mcp.json` | ADO MCP server, VS Code format (`servers`) | VS Code user `mcp.json` (Local harness only) |

`~` is your home folder (`%USERPROFILE%` on Windows). If `COPILOT_HOME` is set, use that folder instead of `~/.copilot`.

Copilot CLI reads `~/.copilot/` directly. VS Code reads the same `~/.copilot/` files when the chat uses the **Copilot** agent harness. Install those two files once and both clients use them.

## Setup

1. **Sign in** with your work Entra account. The Azure DevOps org must be Entra-backed.
2. **MCP server.** Copy `mcp-config.json` to `~/.copilot/mcp-config.json`. If that file already exists, merge the `ado-remote-mcp` entry into its `mcpServers` object instead of overwriting it. Alternatively, run:
   ```sh
   copilot mcp add --transport http ado-remote-mcp https://mcp.dev.azure.com/YOUR_ORG
   ```
   That command writes the same entry. The CLI does not read `.vscode/mcp.json`.
3. **Instructions.** Copy `copilot-instructions.md` to `~/.copilot/copilot-instructions.md`. If you already have one, append these rules to it.
   - macOS/Linux: `mkdir -p ~/.copilot && cp copilot-instructions.md ~/.copilot/`
   - Windows (PowerShell): `New-Item -ItemType Directory -Force $HOME\.copilot; Copy-Item copilot-instructions.md $HOME\.copilot\`
4. **Confirm in the CLI.** Run `/instructions` to check the file is listed and enabled, and `/mcp` to check `ado-remote-mcp`. Two GitHub issues report this file not loading in some CLI versions.
5. **Confirm in VS Code.** Pick the **Copilot** harness in the chat view, run **Chat: Open Customizations**, and check that the instructions file appears under **Instructions** and `ado-remote-mcp` under **MCP Servers**.

### VS Code with the Local harness (or older VS Code)

The Local harness does not read `~/.copilot/`. Use the VS Code-format files instead:

- **MCP:** run **MCP: Open User Configuration** and merge in the contents of `vscode-mcp.json`.
- **Instructions:** run **Chat: Open Customizations** > **Instructions**, select **+** next to **User**, and paste the contents of `ado-work-items.instructions.md`. On older builds, use **Chat: New Instructions File** and choose **User**.

## Test

In each client:

1. Ask: "What ADO rules are you following?"
2. Ask it to draft one PBI with two Tasks under a test Feature. **Do not approve it.** Check that it shows the draft table and waits.

## Check first

These are unverified:

- Whether `wit_add_child_work_items` can set Acceptance Criteria and Assigned To. The rules include a fallback (update afterward, or create and link).
- Whether new items leave Iteration Path unset.
- Whether the CLI's Entra sign-in works smoothly with the remote server.
- Whether the `applyTo: "**"` file attaches in a chat that touches no files. The docs say `applyTo` matches files the agent works with, which is why the main setup uses `copilot-instructions.md`. If it doesn't attach, attach it manually via **Add Context > Instructions**.
