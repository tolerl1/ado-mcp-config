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
| `vscode/prompts/draft-backlog.prompt.md` | A VS Code **User** prompt file (optional) |
| `vscode/prompts/create-backlog.prompt.md` | A VS Code **User** prompt file (optional) |

`~` is your home folder (`%USERPROFILE%` on Windows).

**Copilot CLI** needs the first two files.

- **MCP:** merge `copilot-cli/mcp-config.json` into `~/.copilot/mcp-config.json` (root key `mcpServers`). If you have no file yet, copy it as is. Or skip the file and run:
  ```sh
  copilot mcp add --transport http ado-remote-mcp https://mcp.dev.azure.com/YOUR_ORG
  ```
  The CLI does not read `.vscode/mcp.json`.
- **Instructions:** copy `copilot-cli/copilot-instructions.md` to `~/.copilot/copilot-instructions.md`. If that file already exists, append the rules to it instead of replacing it.

**VS Code** needs the next two files, plus the optional prompt files.

- **MCP:** run **MCP: Open User Configuration** and merge in `vscode/mcp.json` (root key `servers`). Default paths, if you don't use a custom profile:
  - Windows: `%APPDATA%\Code\User\mcp.json`
  - macOS: `~/Library/Application Support/Code/User/mcp.json`
  - Linux: `~/.config/Code/User/mcp.json`
- **Instructions:** run **Chat: New Instructions File**, choose **User**, and paste in `vscode/ado-work-items.instructions.md`.
- **Prompt files (optional):** for each file in `vscode/prompts/`, run **Chat: New Prompt File**, choose **User**, name it the same (`draft-backlog`, `create-backlog`), and paste in the contents. They show up in chat as `/draft-backlog` and `/create-backlog`.

VS Code chat has two agent harnesses. The **Local** harness reads the VS Code files above. The **Copilot** harness reads the `~/.copilot/` files. Set up the four required files and either one works.

**First use:** sign in with your work Microsoft Entra account when prompted. The Azure DevOps organization must be backed by Entra; personal Microsoft account organizations aren't supported by the remote server. Don't also run the local Azure DevOps MCP server.

## How to use it

- There is no slash command or trigger word. The rules load automatically as instructions. Start an agent-mode chat in VS Code (**Chat > Agent**), or a CLI session, and ask in plain language, for example:
  > In project X, create 3 PBIs under Feature 1234 for the login redesign, with tasks for each.
- Name the project and the parent Feature ID in each prompt. The agent copies the Area Path from the parent Feature and leaves Iteration unset unless you give a sprint.
- The agent shows a draft table first. Reply "approved" or ask for edits. Nothing is written until you approve.
- To find your team name, ask: "List the teams in project X."
- To create a Feature, give the parent Epic ID.
- VS Code also asks you to confirm each MCP tool call. Don't choose "always allow" for create or update tools until you trust the output.

## Two-step flow: spec to backlog file to ADO

Instead of describing items in chat, you can have Copilot draft a backlog file first, edit it, and then create everything from that file. `backlog-template.md` shows the format.

1. **Draft.** Attach the spec or planning notes and ask for a backlog. In VS Code: `/draft-backlog` with the spec attached (**Add Context**, or `#file:specs/login-redesign.md`). In the CLI, or without the prompt files:
   > Draft a backlog from specs/login-redesign.md for project X under Feature 1234.

   Copilot writes `backlog/<short-name>.md` and lists open questions. It doesn't touch Azure DevOps in this step.
2. **Edit** the file: fix titles, criteria, and tasks, answer the open questions, and fill in `project` and `parent` if they're blank.
3. **Create.** In VS Code: `/create-backlog` with the file open or its path given. Otherwise:
   > Create the items in backlog/login-redesign.md.

   Copilot shows the usual draft table, waits for "approved", creates the items, and writes each new ID into the file's `<!-- ado-id: -->` comments.

The file stays the record of what was created. If a run stops partway, run step 3 again: items that already have an ID are skipped. If you ask for changes at the approval step, Copilot edits the file first. The file is also still usable for manual copy-paste.

Commit the backlog files next to the spec if you want a history; otherwise keep them anywhere in the workspace.

## Verify it works

- **VS Code:** open Chat in Agent mode, click **Select Tools**, and confirm `ado-remote-mcp` is listed. Ask "List the projects in my Azure DevOps organization," then "What ADO rules are you following?"
- **CLI:** run `/mcp` to list servers and `/instructions` to confirm the rules loaded. Two GitHub issues report `copilot-instructions.md` not loading in some CLI versions.
- Then run the test: draft one PBI with two Tasks under a test Feature and **do not approve it**. Check that it shows the draft table and waits.
- **Two-step flow:** ask for a backlog draft from a short spec. Check that it writes the file and makes no MCP calls. Then run the create step against a test Feature, approve, and check that the IDs are written back. Run the create step again and check that everything is skipped.

## Check first (unverified)

- Whether the child-creation action (`wit_work_item_write` with `action: add_child`) can set Acceptance Criteria. The rules include a fallback: update the item afterward, or create it and link it.
- Whether new items leave Iteration Path unset.
- Whether Copilot CLI's Entra sign-in works smoothly with the remote server. Microsoft lists the CLI as supported, but this hasn't been tested here.
- Whether VS Code attaches an `applyTo: "**"` file in a chat that touches no files. If not, attach it manually via **Add Context > Instructions**.
- Prompt file frontmatter: the files use `agent: agent`. Older VS Code versions used `mode: agent` instead; change it if the prompt doesn't run in agent mode.
- Whether Copilot CLI has an equivalent of VS Code prompt files. The two-step flow works in the CLI with plain-language prompts either way, because the rules are in `copilot-instructions.md`.
