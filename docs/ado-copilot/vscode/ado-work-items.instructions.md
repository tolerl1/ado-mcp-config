---
description: Rules for drafting backlogs and creating Azure DevOps Features, PBIs, and Tasks via the ADO MCP server
applyTo: "**"
---

# Azure DevOps work item rules

Applies whenever I ask you to draft a backlog from a spec or planning
notes, or to create or change Azure DevOps work items with the Azure
DevOps MCP server.

## Hierarchy
Epic > Feature > Product Backlog Item (PBI) > Task.
- Epics already exist. Never create or edit Epics.
- I create Features, PBIs, and Tasks.
- Every Feature has a parent Epic, every PBI a parent Feature,
  every Task a parent PBI.
- If I don't give the parent ID, ask. Never create orphans.

## Scope
- If I don't name a project, ask. To find a team name, list the
  project's teams.
- Area Path: read the parent Feature and copy its Area Path unless
  I give one.
- Iteration: leave unset unless I give a sprint. Tell me if the tool
  assigned one anyway.
- Leave Effort, Priority, and Business Value empty. Leave Assigned To
  empty unless I name someone.

## Fields
- Feature: Title, Description.
- PBI: Title, Description, Acceptance Criteria.
- Task: Title, brief Description.
- Description and Acceptance Criteria are HTML fields. Write lists as
  <ul><li> so they render properly.
- Titles are short and specific. Acceptance Criteria is a testable
  checklist.
- Tasks are a checklist-style breakdown, one concrete action each,
  e.g. "Assign permissions", "Update section 2 of the user guide".

## Creating
- Use `wit_work_item_write` with `action: add_child` to create items
  under a parent. It sets the parent link, Title, Description, Area
  Path, and Iteration Path, and nothing else. Pass `format: "Html"`
  with HTML content (the tool defaults to Markdown). Create up to 50
  children per call.
- `add_child` cannot set Acceptance Criteria. After creating PBIs,
  set `Microsoft.VSTS.Common.AcceptanceCriteria` with `update_batch`
  (or `update`), as HTML.
- If a create fails partway, stop and report what was created. Don't
  retry without asking.
- After creating, verify each item's parent and fields.
- Before creating an item that has no `ado-id`, read the parent's
  existing child items. If one has the same title, don't create a
  duplicate: tell me and ask whether to reuse its ID. This covers a
  run that stopped after creating an item but before its ID was
  written to the file.

## Drafting from a spec (step 1)
- When I give you a spec, planning notes, or a meeting transcript and
  ask for a backlog, write a markdown backlog file. Don't call any
  Azure DevOps tools in this step, not even reads, unless I ask.
- Save it as `backlog/<short-name>.md` unless I name a path. Never
  overwrite an existing file without asking.
- Use this format:
  - Frontmatter: `project`, `parent` (Feature ID for PBIs, Epic ID for
    Features), optional `area` and `iteration`, and `source` (the spec
    path or a short note on where the content came from).
  - One `## PBI: <title>` section per PBI, each followed by an empty
    `<!-- ado-id: -->` line, then **Description**, **Acceptance
    criteria** (bullets), and `### Tasks` (one bullet per task:
    `Title: brief description <!-- ado-id: -->`). Split a task bullet
    on the first `: ` only: everything before it is the Title and
    everything after (up to the comment) is the Description. A bullet
    with no `: ` is a Title with no Description.
  - When the parent is an Epic, use `## Feature: <title>` sections with
    `### PBI:` sections inside and `#### Tasks` under each PBI.
  - When the parent is a PBI, use `## Task: <title>` sections, each
    followed by an `<!-- ado-id: -->` line and a brief description.
  - End with `## Open questions`.
- Leave frontmatter values blank if I haven't given them; don't guess
  IDs or project names.
- Stay close to the spec's wording. Don't invent scope. Put anything
  unclear or missing under Open questions instead of guessing.
- Apply the Fields rules above to titles, acceptance criteria, and
  tasks. Write plain markdown bullets here; convert them to HTML only
  when creating.
- When done, give the file path, a count of items by type, and the
  open questions.

## Creating from a backlog file (step 2)
- When I ask to create the items in a backlog file, read the file and
  use its frontmatter for project, parent, area, and iteration. If
  `project` or `parent` is blank, ask.
- Skip any item that already has an `ado-id` and say which ones you
  skipped. Don't update existing items unless I ask.
- If the Open questions section still has items, list them and ask
  whether to continue.
- Follow the Approval rules: show the draft table built from the file
  and wait for my approval. If I ask for changes, edit the file first,
  then re-show the table, so the file stays the source of truth.
- Convert markdown bullets to `<ul><li>` HTML for Description and
  Acceptance Criteria. Parse task bullets as described in step 1.
- After each item is created, write its ID into that item's
  `<!-- ado-id: -->` comment right away, so a partial run can be
  resumed without duplicates.

## Approval (always)
1. Never create or update anything before I approve.
2. First show one draft table for the whole request: type, title,
   parent (ID and title), area path, and a summary of
   description/acceptance criteria.
3. Wait for my explicit approval. Apply my edits and re-show the table
   if changes are large.
4. After creating, list each item's ID, title, link, and parent.
