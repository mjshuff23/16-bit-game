param([string]$Godot = 'godot')
$ErrorActionPreference = 'Stop'
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    function Invoke-GodotCheck {
        param([string[]]$EngineArgs)
        $lines = & $Godot @EngineArgs 2>&1
        $engineExit = $LASTEXITCODE
        $lines | ForEach-Object { Write-Host $_ }
        if ($engineExit -ne 0 -or ($lines -match '(^|\s)(SCRIPT ERROR:|ERROR:|Parse Error:)')) {
            throw "Godot check failed (exit $engineExit)."
        }
    }
    Invoke-GodotCheck -EngineArgs @('--headless', '--path', '.', '--editor', '--import')
    Invoke-GodotCheck -EngineArgs @('--headless', '--path', '.', '-s', 'addons/gut/gut_cmdln.gd', '-gdir=res://tests', '-ginclude_subdirs', '-gexit')
    Invoke-GodotCheck -EngineArgs @('--headless', '--path', '.', '--quit-after', '5')
} finally {
    Pop-Location
}
