---
description: Draft a backlog markdown file from a spec or planning notes (no ADO changes)
agent: agent
argument-hint: Attach or name the spec, plus project and parent ID if known
---

Draft a backlog file from the spec or planning notes I attached or named
below. Follow the "Drafting from a spec (step 1)" rules in my Azure DevOps
work item instructions.

- Don't call any Azure DevOps tools.
- Use the format from those rules. Leave `project` and `parent` blank if I
  haven't given them.
- Save to `backlog/<short-name>.md` unless I give a path.
- When done, give me the file path, a count of items by type, and the open
  questions.

Input: ${input:source:Spec path, notes, or extra context (project, parent ID)}
