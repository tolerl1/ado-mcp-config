---
project: YOUR_PROJECT
parent: 1234          # Feature ID for PBIs, or Epic ID for Features
area:                 # optional; blank = copy the parent's Area Path
iteration:            # optional; blank = leave unset
source: specs/your-spec.md
---

<!--
Backlog draft. Copilot writes this file from a spec or planning notes
(step 1), you edit it, then Copilot creates the items from it (step 2).

- Each "## PBI:" section is a child of `parent`.
- When `parent` is an Epic, use "## Feature:" sections instead, with
  "### PBI:" sections inside them and "#### Tasks" under each PBI.
- Leave `ado-id` blank. Copilot fills it in after creating the item and
  skips items that already have an ID, so a re-run won't duplicate them.
- Plain bullets are fine; Copilot converts them to HTML lists in ADO.
-->

## PBI: Add SSO sign-in option
<!-- ado-id: -->

**Description**
Users can sign in with their work account instead of a separate password.

**Acceptance criteria**
- User can sign in with Entra ID from the sign-in page
- Failed sign-in shows an error message and a retry option
- Existing password sign-in still works

### Tasks
- Configure Entra app registration: register the app and set redirect URIs <!-- ado-id: -->
- Update sign-in page UI: add the "Sign in with work account" button <!-- ado-id: -->
- Update section 2 of the user guide <!-- ado-id: -->

## Open questions
- Questions from the spec that need an answer before these items are created.
