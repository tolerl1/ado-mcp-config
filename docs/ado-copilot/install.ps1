# Installs the Azure DevOps work item rules for GitHub Copilot (Windows).
# Copies copilot-instructions.md to ~/.copilot/ (backing up any existing file).
# Never writes MCP config files: it prints the snippet to merge and where.
$ErrorActionPreference = 'Stop'

$ScriptDir = $PSScriptRoot
$CopilotDir = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $HOME '.copilot' }

foreach ($f in 'copilot-instructions.md', 'ado-work-items.instructions.md', 'vscode-user-mcp.json', 'copilot-cli-mcp-config.json') {
    if (-not (Test-Path -LiteralPath (Join-Path $ScriptDir $f) -PathType Leaf)) {
        Write-Error "Missing $f next to this script. Run it from docs\ado-copilot\."
    }
}

$Org = (Read-Host 'Azure DevOps organization name (from https://dev.azure.com/<org>)') -replace '\s', ''
if ($Org -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
    Write-Error "Invalid organization name: '$Org'"
}

# 1. Copilot CLI instructions
New-Item -ItemType Directory -Force -Path $CopilotDir | Out-Null
$Source = Join-Path $ScriptDir 'copilot-instructions.md'
$Target = Join-Path $CopilotDir 'copilot-instructions.md'
if ((Test-Path -LiteralPath $Target) -and
    ((Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $Target).Hash)) {
    Write-Host "Instructions already up to date: $Target"
} else {
    if (Test-Path -LiteralPath $Target) {
        $Backup = "$Target.bak"
        if (Test-Path -LiteralPath $Backup) {
            $Backup = "$Target.$(Get-Date -Format 'yyyyMMddHHmmss').bak"
        }
        Copy-Item -LiteralPath $Target -Destination $Backup
        Write-Host "Backed up existing instructions to: $Backup"
    }
    Copy-Item -LiteralPath $Source -Destination $Target -Force
    Write-Host "Installed instructions: $Target"
}

# 2. MCP config (print only)
$VsCodeMcp = Join-Path $env:APPDATA 'Code\User\mcp.json'
$CliMcp = Join-Path $CopilotDir 'mcp-config.json'

Write-Host ''
Write-Host '=== VS Code MCP (not written) ==='
Write-Host 'Run "MCP: Open User Configuration" and merge this under the "servers" key.'
Write-Host "Default path: $VsCodeMcp"
(Get-Content -Raw -LiteralPath (Join-Path $ScriptDir 'vscode-user-mcp.json')) -replace 'YOUR_ORG', $Org | Write-Host

Write-Host ''
Write-Host '=== Copilot CLI MCP (not written) ==='
Write-Host "Merge this under the ""mcpServers"" key in: $CliMcp"
(Get-Content -Raw -LiteralPath (Join-Path $ScriptDir 'copilot-cli-mcp-config.json')) -replace 'YOUR_ORG', $Org | Write-Host
Write-Host 'Or run instead:'
Write-Host "  copilot mcp add --transport http ado-remote-mcp https://mcp.dev.azure.com/$Org"

Write-Host ''
Write-Host '=== VS Code instructions (manual) ==='
Write-Host 'Run "Chat: New Instructions File", choose User, and paste the contents of:'
Write-Host "  $(Join-Path $ScriptDir 'ado-work-items.instructions.md')"

Write-Host ''
Write-Host 'Sign in with your work Entra account when prompted.'
