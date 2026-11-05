# Azure DevOps work items with Copilot (VS Code and CLI)

User-level files that let GitHub Copilot create Azure DevOps Features, PBIs, and Tasks from VS Code chat and Copilot CLI, using Microsoft's remote Azure DevOps MCP server and a fixed set of rules. Set them up once and they apply to every project.

## User-level setup (applies to all projects)

First, in the two MCP files, replace `YOUR_ORG` with your Azure DevOps organization name (the `<org>` in `https://dev.azure.com/<org>`).

| File in this folder | Copy to |
|---|---|
| `copilot-cli/mcp-config.json` | `~/.copilot/mcp-config.json` |
| `copilot-cli/copilot-instructions.md` | `~/.copilot/copilot-instructions.md` |
| `vscode/mcp.json` | VS Code user `mcp.json` (paths below) |
| `vscode/ado-work-items.instructions.md` | A VS Code **User** instructions file |

`~` is your home folder (`%USERPROFILE%` on Windows).

**Copilot CLI** needs the first two files.

- **MCP:** merge `copilot-cli/mcp-config.json` into `~/.copilot/mcp-config.json` (root key `mcpServers`). If you have no file yet, copy it as is. Or skip the file and run:
  ```sh
  copilot mcp add --transport http ado-remote-mcp https://mcp.dev.azure.com/YOUR_ORG
  ```
  The CLI does not read `.vscode/mcp.json`.
- **Instructions:** copy `copilot-cli/copilot-instructions.md` to `~/.copilot/copilot-instructions.md`. If that file already exists, append the rules to it instead of replacing it.

**VS Code** needs the last two files.

- **MCP:** run **MCP: Open User Configuration** and merge in `vscode/mcp.json` (root key `servers`). Default paths, if you don't use a custom profile:
  - Windows: `%APPDATA%\Code\User\mcp.json`
  - macOS: `~/Library/Application Support/Code/User/mcp.json`
  - Linux: `~/.config/Code/User/mcp.json`
- **Instructions:** run **Chat: New Instructions File**, choose **User**, and paste in `vscode/ado-work-items.instructions.md`.

VS Code chat has two agent harnesses. The **Local** harness reads the VS Code files above. The **Copilot** harness reads the `~/.copilot/` files. Set up all four files and either one works.

**First use:** sign in with your work Microsoft Entra account when prompted. The Azure DevOps organization must be backed by Entra; personal Microsoft account organizations aren't supported by the remote server. Don't also run the local Azure DevOps MCP server.

## How to use it

- There is no slash command or trigger word. The rules load automatically as instructions. Start an agent-mode chat in VS Code (**Chat > Agent**), or a CLI session, and ask in plain language, for example:
  > In project X, create 3 PBIs under Feature 1234 for the login redesign, with tasks for each.
- Name the project and the parent Feature ID in each prompt. The agent copies the Area Path from the parent Feature and leaves Iteration unset unless you give a sprint.
- The agent shows a draft table first. Reply "approved" or ask for edits. Nothing is written until you approve.
- To find your team name, ask: "List the teams in project X."
- To create a Feature, give the parent Epic ID.
- VS Code also asks you to confirm each MCP tool call. Don't choose "always allow" for create or update tools until you trust the output.

## Verify it works

- **VS Code:** open Chat in Agent mode, click **Select Tools**, and confirm `ado-remote-mcp` is listed. Ask "List the projects in my Azure DevOps organization," then "What ADO rules are you following?"
- **CLI:** run `/mcp` to list servers and `/instructions` to confirm the rules loaded. Two GitHub issues report `copilot-instructions.md` not loading in some CLI versions.
- Then run the test: draft one PBI with two Tasks under a test Feature and **do not approve it**. Check that it shows the draft table and waits.

## Check first (unverified)

- Whether the child-creation action (`wit_work_item_write` with `action: add_child`) can set Acceptance Criteria. The rules include a fallback: update the item afterward, or create it and link it.
- Whether new items leave Iteration Path unset.
- Whether Copilot CLI's Entra sign-in works smoothly with the remote server. Microsoft lists the CLI as supported, but this hasn't been tested here.
- Whether VS Code attaches an `applyTo: "**"` file in a chat that touches no files. If not, attach it manually via **Add Context > Instructions**.
