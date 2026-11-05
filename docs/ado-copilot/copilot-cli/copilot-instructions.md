# Azure DevOps work item rules

Applies whenever I ask you to create or change Azure DevOps work items
with the Azure DevOps MCP server.

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
- Leave Effort, Priority, and Business Value empty.

## Fields
- Feature: Title, Description, Assigned To.
- PBI: Title, Description, Acceptance Criteria, Assigned To.
- Task: Title, brief Description, Assigned To.
- Assigned To is me (the signed-in user) unless I name someone. If you
  can't determine my identity, ask before drafting.
- Description and Acceptance Criteria are HTML fields. Write lists as
  <ul><li> so they render properly.
- Titles are short and specific. Acceptance Criteria is a testable
  checklist.
- Tasks are a checklist-style breakdown, one concrete action each,
  e.g. "Assign permissions", "Update section 2 of the user guide".

## Creating
- For children of a parent, prefer the tool's add-child action over
  creating the item and linking it separately. If it can't set a field
  (Acceptance Criteria, Assigned To), set it with an update afterward,
  or create the item and link it to its parent.
- If a create fails partway, stop and report what was created. Don't
  retry without asking.
- After creating, verify each item's parent and fields.

## Approval (always)
1. Never create or update anything before I approve.
2. First show one draft table for the whole request: type, title,
   parent (ID and title), area path, assigned to, and a summary of
   description/acceptance criteria.
3. Wait for my explicit approval. Apply my edits and re-show the table
   if changes are large.
4. After creating, list each item's ID, title, link, and parent.
