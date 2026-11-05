---
project: YOUR_PROJECT
parent: 1000          # Epic ID (Features are created under it)
area:                 # optional; blank = copy the parent's Area Path
iteration:            # optional; blank = leave unset
source: specs/your-spec.md
---

<!--
Backlog draft: Features under one Epic, each with PBIs and Tasks.
Features have a Title and Description only. Epics are never created.
Leave `ado-id` blank; Copilot fills it in.
-->

## Feature: Single sign-on
<!-- ado-id: -->

**Description**
Let users sign in with their work account across the web app.

### PBI: Add SSO sign-in option
<!-- ado-id: -->

**Description**
Users can sign in with their work account instead of a separate password.

**Acceptance criteria**
- User can sign in with Entra ID from the sign-in page
- Existing password sign-in still works

#### Tasks
- Configure Entra app registration: register the app and set redirect URIs <!-- ado-id: -->
- Update sign-in page UI: add the "Sign in with work account" button <!-- ado-id: -->

## Open questions
- Questions from the spec that need an answer before these items are created.
