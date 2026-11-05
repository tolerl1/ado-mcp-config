# Azure DevOps work items with Copilot (VS Code and CLI)

User-level files that let GitHub Copilot create Azure DevOps Features, PBIs, and Tasks from VS Code chat and Copilot CLI, using Microsoft's remote Azure DevOps MCP server and a fixed set of rules. Set them up once and they apply to every project.

## User-level setup (applies to all projects)

### Quick install (PowerShell)

```powershell
.\install.ps1 -Org <org>
```

`<org>` is your Azure DevOps organization name (the `<org>` in `https://dev.azure.com/<org>`). The script does everything in the manual steps below: it fills in the org name, merges into existing MCP files (backing them up as `*.bak`), adds the rules to `copilot-instructions.md` inside marked lines (re-running replaces just that block), and copies the VS Code instructions and prompt files. Use `-SkipCLI` or `-SkipVSCode` to do one side only. It puts the VS Code instructions and prompt files in a `prompts` folder under the VS Code user folder. I could not confirm that path in the VS Code docs, so after installing, check that the files show up (**Chat: Configure Prompt Files**). If not, pass the right folder with `-VSCodePromptsDir`. I haven't run the script on Windows.

### Manual setup

First, in the two MCP files, replace `YOUR_ORG` with your Azure DevOps organization name.

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

VS Code chat has two agent harnesses. The **Local** harness reads the VS Code files above. The **Copilot** harness reads the `~/.copilot/` files. Set up the four required files and either one works. Prompt files (`/draft-backlog`, `/create-backlog`) work only in the Local harness; in the Copilot harness use plain-language prompts.

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

Instead of describing items in chat, you can have Copilot draft a backlog file first, edit it, and then create everything from that file. The files in `templates/` show the format: `backlog.md` (PBIs and Tasks under a Feature), `feature.md` (Features under an Epic), and `task.md` (Tasks under an existing PBI).

1. **Draft.** Attach the spec or planning notes and ask for a backlog. In VS Code: `/draft-backlog` with the spec attached (**Add Context**, or `#file:specs/login-redesign.md`). In the CLI, or without the prompt files:
   > Draft a backlog from specs/login-redesign.md for project X under Feature 1234.

   Copilot writes `backlog/<short-name>.md` and lists open questions. It doesn't touch Azure DevOps in this step.
2. **Edit** the file: fix titles, criteria, and tasks, answer the open questions, and fill in `project` and `parent` if they're blank.
3. **Create.** In VS Code: `/create-backlog` with the file open or its path given. Otherwise:
   > Create the items in backlog/login-redesign.md.

   Copilot shows the usual draft table, waits for "approved", creates the items, and writes each new ID into the file's `<!-- ado-id: -->` comments.

The file stays the record of what was created. If a run stops partway, run step 3 again: items that already have an ID are skipped. If you ask for changes at the approval step, Copilot edits the file first. The file is also still usable for manual copy-paste.

Backlog files are working drafts in the project you run Copilot in, not part of this repo. You don't need to commit them. Keep them anywhere in that workspace, or delete them once the items exist in Azure DevOps.

## Verify it works

- **VS Code:** open Chat in Agent mode, click **Select Tools**, and confirm `ado-remote-mcp` is listed. Ask "List the projects in my Azure DevOps organization," then "What ADO rules are you following?"
- **CLI:** run `/mcp` to list servers and `/instructions` to confirm the rules loaded. Two GitHub issues report `copilot-instructions.md` not loading in some CLI versions.
- Then run the test: draft one PBI with two Tasks under a test Feature and **do not approve it**. Check that it shows the draft table and waits.
- **Two-step flow:** ask for a backlog draft from a short spec. Check that it writes the file and makes no MCP calls. Then run the create step against a test Feature, approve, and check that the IDs are written back. Run the create step again and check that everything is skipped.

## What was checked against the docs

Checked against Microsoft and VS Code documentation and the open-source Azure DevOps MCP server code (the remote server is described as a hosted version of it, but the remote tool list may differ slightly, so confirm with the test below):

- **Acceptance Criteria with `add_child`: not supported.** `add_child` sets only Title, Description, Area Path, Iteration Path, and the parent link. Its Description format defaults to Markdown. The rules now create PBIs with `add_child` (passing HTML), then set Acceptance Criteria with `update_batch`.
- **Iteration:** `add_child` sets Iteration Path only if one is passed. What Azure DevOps assigns when it's omitted isn't documented, so the rules keep the "tell me if one was assigned" check.
- **Remote server and clients:** The remote server needs a Microsoft Entra-backed organization, and Microsoft lists VS Code with GitHub Copilot and GitHub Copilot CLI as supported ([setup](https://learn.microsoft.com/azure/devops/mcp-server/remote-mcp-server)). Don't run the local server alongside it.
- **Prompt file frontmatter:** the current VS Code docs use `agent:` (`mode:` was the April 2025 name).
- **CLI files:** `~/.copilot/copilot-instructions.md` and `~/.copilot/mcp-config.json` are documented user-level locations. Edits to instructions apply only to new or resumed sessions.

## Still unverified

- Whether `applyTo: "**"` attaches in a VS Code chat with no files in context. The docs don't say. If not, attach it via **Add Context > Instructions**.
- The location of the VS Code User `prompts` folder (see Quick install).
- Whether the remote server's `add_child` matches the open-source schema above.
- Whether Copilot CLI's Entra sign-in works smoothly with the remote server (listed as supported, not tested here).
