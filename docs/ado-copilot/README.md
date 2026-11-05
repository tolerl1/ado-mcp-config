# Azure DevOps work item rules for GitHub Copilot

User-level setup so GitHub Copilot (VS Code and CLI) creates Azure DevOps Features, PBIs, and Tasks the same way, through the remote Azure DevOps MCP server.

Replace `YOUR_ORG` with your Azure DevOps organization name.

## Files

| File | For |
|---|---|
| `ado-work-items.instructions.md` | VS Code user instructions (rules with frontmatter) |
| `vscode-user-mcp.json` | VS Code user MCP config (root key `servers`) |
| `copilot-instructions.md` | Copilot CLI instructions (same rules, no frontmatter) |
| `copilot-cli-mcp-config.json` | Copilot CLI MCP config (root key `mcpServers`) |
| `install.ps1` / `install.sh` | Windows / macOS and Linux installer |

The installers ask for your org name, copy `copilot-instructions.md` to `~/.copilot/` (backing up any existing file as `.bak`), and print the MCP snippets, their target paths, and the manual VS Code step. They never write MCP config files.

```sh
./install.sh                                          # macOS/Linux
powershell -ExecutionPolicy Bypass -File .\install.ps1  # Windows
```

## User-level setup (applies to all projects)

**VS Code**
- **MCP:** run **MCP: Open User Configuration** and merge `vscode-user-mcp.json` into it (root key is `servers`). Default paths, if not using a custom profile:
  - Windows: `%APPDATA%\Code\User\mcp.json`
  - macOS: `~/Library/Application Support/Code/User/mcp.json`
  - Linux: `~/.config/Code/User/mcp.json`
- **Instructions:** run **Chat: New Instructions File**, choose **User**, and paste `ado-work-items.instructions.md`.

**Copilot CLI**
- **MCP:** either run
  ```sh
  copilot mcp add --transport http ado-remote-mcp https://mcp.dev.azure.com/YOUR_ORG
  ```
  or merge `copilot-cli-mcp-config.json` into `~/.copilot/mcp-config.json` (root key is `mcpServers`). The CLI does not read `.vscode/mcp.json`.
- **Instructions:** copy `copilot-instructions.md` to `~/.copilot/copilot-instructions.md`.

**First use:** sign in with your work Entra account when prompted. The Azure DevOps org must be Entra-backed.

## How to use it

- There is no slash command or trigger word. The rules load automatically as instructions. Start an agent-mode chat in VS Code (**Chat > Agent**), or a CLI session, and ask in plain language, e.g.:
  > In project X, create 3 PBIs under Feature 1234 for &lt;topic&gt;, with tasks for each.
- Name the project and parent Feature ID in each prompt. The agent copies the Area Path from the parent Feature and leaves Iteration unset unless you give a sprint.
- The agent shows a draft table first. Reply "approved" (or request edits). Nothing is written until you approve.
- To find your team name, ask: "List the teams in project X."
- To create a Feature, give the parent Epic ID.
- VS Code will also ask you to confirm each MCP tool call. Don't set "always allow" on create/update tools until you trust the output.

## Verify it works

- **VS Code:** open Chat in Agent mode, click **Select Tools**, and confirm `ado-remote-mcp` is listed. Ask "What ADO rules are you following?"
- **CLI:** run `/mcp` to list servers and `/instructions` to confirm the instructions loaded. Two GitHub issues report `copilot-instructions.md` not loading in some CLI versions.
- Then run the test: draft one PBI with two Tasks under a test Feature and **do not approve it**.

## Check first (unverified)

- Whether `wit_add_child_work_items` can set Acceptance Criteria and Assigned To. The rules include a fallback (update afterward, or create and link).
- Whether new items leave Iteration Path unset.
- Whether the CLI's Entra sign-in works smoothly with the remote server.
- Whether VS Code attaches an `applyTo: "**"` file in a chat that touches no files. If not, attach it manually via **Add Context > Instructions**.
