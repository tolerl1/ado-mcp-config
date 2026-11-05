# Azure DevOps work item rules for GitHub Copilot

Shared rules so GitHub Copilot (CLI and VS Code) creates Azure DevOps Features, PBIs, and Tasks the same way, through the remote Azure DevOps MCP server.

## Files

| File | Used by | Install location |
|---|---|---|
| `copilot-instructions.md` | GitHub Copilot CLI | `~/.copilot/copilot-instructions.md` |
| `ado-work-items.instructions.md` | VS Code (user instructions) | User instructions file, created via "Chat: New Instructions File" |

Both contain the same rules. The VS Code file adds frontmatter (`description`, `applyTo: "**"`).

Replace `YOUR_ORG` below with your Azure DevOps organization name.

## Setup

1. **VS Code MCP server.** Run **MCP: Open User Configuration** and add:
   ```json
   { "servers": { "ado-remote-mcp": { "type": "http", "url": "https://mcp.dev.azure.com/YOUR_ORG" } } }
   ```
2. **Copilot CLI MCP server.**
   ```sh
   copilot mcp add --transport http ado-remote-mcp https://mcp.dev.azure.com/YOUR_ORG
   ```
   This writes to `~/.copilot/mcp-config.json`. The CLI does not read `.vscode/mcp.json`.
3. **CLI instructions.** Copy `copilot-instructions.md` to `~/.copilot/copilot-instructions.md`, then run `/instructions` in the CLI to confirm it loaded. Two GitHub issues report this file not loading in some CLI versions.
4. **VS Code instructions.** Run **Chat: New Instructions File**, choose **User**, and paste the contents of `ado-work-items.instructions.md`.
5. **Sign in** with your work Entra account. The Azure DevOps org must be Entra-backed.

## Test

In each client:

1. Ask: "What ADO rules are you following?"
2. Ask it to draft one PBI with two Tasks under a test Feature. **Do not approve it.** Check that it shows the draft table and waits.

## Check first

These are unverified:

- Whether `wit_add_child_work_items` can set Acceptance Criteria and Assigned To. The rules include a fallback (update afterward, or create and link).
- Whether new items leave Iteration Path unset.
- Whether the CLI's Entra sign-in works smoothly with the remote server.
- Whether VS Code attaches an `applyTo: "**"` file in a chat that touches no files. If not, attach it manually via **Add Context > Instructions**.
