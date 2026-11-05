---
description: Create Azure DevOps work items from a backlog markdown file, after approval
agent: agent
argument-hint: Backlog file path, e.g. backlog/login-redesign.md
---

Create the Azure DevOps work items in the backlog file below. Follow the
"Creating from a backlog file (step 2)" and "Approval (always)" rules in my
Azure DevOps work item instructions.

- Read project, parent, area, and iteration from the file's frontmatter.
  Ask if `project` or `parent` is blank.
- Skip items that already have an `ado-id`.
- Show the draft table and wait for my explicit approval before creating
  anything.
- After each item is created, write its ID into the file.

Backlog file: ${input:file:Backlog file path (or leave blank to use the open file)}

If no path is given, use the currently open file: ${file}
