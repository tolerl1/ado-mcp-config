<#
.SYNOPSIS
  Installs the Azure DevOps Copilot files for VS Code and Copilot CLI.

.DESCRIPTION
  Copies the files in this folder to their user-level locations (see
  README.md), replacing YOUR_ORG with your organization name. Existing
  MCP config files are merged, not overwritten, and are backed up first.
  Existing copilot-instructions.md content is kept; the ADO rules are
  added inside marked lines and replaced on re-run.

.EXAMPLE
  .\install.ps1 -Org contoso

.EXAMPLE
  .\install.ps1 -Org contoso -SkipCLI
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
    [string]$Org,

    [switch]$SkipVSCode,
    [switch]$SkipCLI,

    # Override for VS Code Insiders or a custom profile,
    # e.g. "$env:APPDATA\Code - Insiders\User".
    [string]$VSCodeUserDir,

    # Folder for the User instructions and prompt files. Default:
    # "prompts" inside the VS Code user folder. If you use a custom
    # profile, find the folder with "Chat: Configure Prompt Files".
    [string]$VSCodePromptsDir,

    # Override for the Copilot CLI folder. Default: ~/.copilot
    [string]$CopilotDir
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$BeginMarker = '<!-- BEGIN ado-work-item-rules -->'
$EndMarker = '<!-- END ado-work-item-rules -->'

function Write-Text([string]$Path, [string]$Text) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Read-Source([string]$RelativePath) {
    $full = Join-Path $PSScriptRoot $RelativePath
    if (-not (Test-Path -LiteralPath $full)) {
        throw "Missing source file: $full"
    }
    return [System.IO.File]::ReadAllText($full)
}

function Backup-File([string]$Path) {
    $backup = "$Path.bak"
    Copy-Item -LiteralPath $Path -Destination $backup -Force
    Write-Host "  Backed up existing file to $backup"
}

# Merge the single server from a source MCP file into the target file.
# $RootKey is 'mcpServers' (CLI) or 'servers' (VS Code).
function Merge-McpConfig([string]$SourceRelative, [string]$TargetPath, [string]$RootKey) {
    $sourceText = (Read-Source $SourceRelative).Replace('YOUR_ORG', $Org)

    if (-not (Test-Path -LiteralPath $TargetPath)) {
        Write-Text $TargetPath $sourceText
        Write-Host "  Created $TargetPath"
        return
    }

    $source = $sourceText | ConvertFrom-Json
    try {
        $target = [System.IO.File]::ReadAllText($TargetPath) | ConvertFrom-Json
    }
    catch {
        Write-Warning "Could not parse $TargetPath (comments or invalid JSON?). Not changed."
        Write-Warning "Merge $SourceRelative into it by hand (root key '$RootKey')."
        return
    }
    if ($null -eq $target) { $target = [pscustomobject]@{} }

    Backup-File $TargetPath

    if (-not ($target.PSObject.Properties.Name -contains $RootKey)) {
        $target | Add-Member -NotePropertyName $RootKey -NotePropertyValue ([pscustomobject]@{})
    }
    foreach ($server in $source.$RootKey.PSObject.Properties) {
        $target.$RootKey | Add-Member -NotePropertyName $server.Name -NotePropertyValue $server.Value -Force
        Write-Host "  Set server '$($server.Name)' in $TargetPath"
    }
    Write-Text $TargetPath (($target | ConvertTo-Json -Depth 20) + "`n")
}

# Put the rules in a marked block, keeping anything else in the file.
function Install-MarkedBlock([string]$SourceRelative, [string]$TargetPath) {
    $rules = (Read-Source $SourceRelative).TrimEnd()
    $block = "$BeginMarker`n$rules`n$EndMarker`n"

    if (-not (Test-Path -LiteralPath $TargetPath)) {
        Write-Text $TargetPath $block
        Write-Host "  Created $TargetPath"
        return
    }

    $existing = [System.IO.File]::ReadAllText($TargetPath)
    Backup-File $TargetPath
    $pattern = '(?s)' + [regex]::Escape($BeginMarker) + '.*?' + [regex]::Escape($EndMarker) + '\r?\n?'
    if ($existing -match $pattern) {
        $updated = [regex]::Replace($existing, $pattern, { param($m) $block })
        Write-Host "  Replaced the existing ADO rules block in $TargetPath"
    }
    else {
        $updated = $existing.TrimEnd() + "`n`n" + $block
        Write-Host "  Appended the ADO rules to $TargetPath"
    }
    Write-Text $TargetPath $updated
}

function Install-File([string]$SourceRelative, [string]$TargetPath) {
    if (Test-Path -LiteralPath $TargetPath) {
        $same = (Read-Source $SourceRelative) -ceq [System.IO.File]::ReadAllText($TargetPath)
        if (-not $same) { Backup-File $TargetPath }
    }
    Write-Text $TargetPath (Read-Source $SourceRelative)
    Write-Host "  Wrote $TargetPath"
}

if ($SkipVSCode -and $SkipCLI) {
    throw 'Nothing to do: both -SkipVSCode and -SkipCLI were given.'
}

if (-not $SkipCLI) {
    if (-not $CopilotDir) { $CopilotDir = Join-Path $HOME '.copilot' }
    Write-Host "Copilot CLI ($CopilotDir)"
    Merge-McpConfig 'copilot-cli\mcp-config.json' (Join-Path $CopilotDir 'mcp-config.json') 'mcpServers'
    Install-MarkedBlock 'copilot-cli\copilot-instructions.md' (Join-Path $CopilotDir 'copilot-instructions.md')
}

if (-not $SkipVSCode) {
    if (-not $VSCodeUserDir) {
        if ($env:APPDATA) { $VSCodeUserDir = Join-Path $env:APPDATA 'Code\User' }
        elseif ($IsMacOS) { $VSCodeUserDir = Join-Path $HOME 'Library/Application Support/Code/User' }
        else { $VSCodeUserDir = Join-Path $HOME '.config/Code/User' }
    }
    Write-Host "VS Code ($VSCodeUserDir)"
    Merge-McpConfig 'vscode\mcp.json' (Join-Path $VSCodeUserDir 'mcp.json') 'servers'

    # VS Code keeps User instructions and prompt files in the "prompts" folder.
    $promptsDir = $VSCodePromptsDir
    if (-not $promptsDir) { $promptsDir = Join-Path $VSCodeUserDir 'prompts' }
    Install-File 'vscode\ado-work-items.instructions.md' (Join-Path $promptsDir 'ado-work-items.instructions.md')
    Install-File 'vscode\prompts\draft-backlog.prompt.md' (Join-Path $promptsDir 'draft-backlog.prompt.md')
    Install-File 'vscode\prompts\create-backlog.prompt.md' (Join-Path $promptsDir 'create-backlog.prompt.md')
}

Write-Host ''
Write-Host 'Done. Restart VS Code or start a new Copilot CLI session, then sign in with your'
Write-Host 'work Microsoft Entra account when prompted. See README.md ("Verify it works").'
