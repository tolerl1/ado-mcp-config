---
project: YOUR_PROJECT
parent: 1234          # Feature ID (PBIs are created under it)
area:                 # optional; blank = copy the parent's Area Path
iteration:            # optional; blank = leave unset
source: specs/your-spec.md
---

<!--
Backlog draft: PBIs (with Tasks) under one Feature.
Step 1: Copilot writes this from a spec. You edit it.
Step 2: Copilot creates the items from it.

- Leave `ado-id` blank. Copilot fills it in after creating the item and
  skips items that already have an ID.
- Task bullets are "Title: description". Only the first ": " splits them.
- Plain bullets are fine; Copilot converts them to HTML in ADO.
- For Features under an Epic, see feature.md. For Tasks under an
  existing PBI, see task.md.
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
