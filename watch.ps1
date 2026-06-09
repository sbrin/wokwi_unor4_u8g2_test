param (
    [string]$Fqbn = $env:FQBN,
    [int]$DebounceSeconds = (if ($env:DEBOUNCE_SECONDS) { [int]$env:DEBOUNCE_SECONDS } else { 2 }),
    [switch]$Once = ($env:ONCE -eq 1)
)

if (-not $Fqbn) {
    $Fqbn = "arduino:avr:uno"
}

$ProjectDir = $PSScriptRoot
if (-not $ProjectDir) {
    $ProjectDir = Get-Location
}
$BuildDir = Join-Path $ProjectDir "build"
$SketchFile = Join-Path $ProjectDir "unor4_u8g2_test.ino"
$BuildKey = $Fqbn -replace '[:,/]', '_'
$BuildPath = Join-Path $ProjectDir ".arduino-build" | Join-Path -ChildPath $BuildKey

function Compile-Sketch {
    if (-not (Test-Path $BuildDir)) {
        New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
    }
    if (-not (Test-Path $BuildPath)) {
        New-Item -ItemType Directory -Force -Path $BuildPath | Out-Null
    }

    Write-Host "=== Compiling ($Fqbn)... ==="
    arduino-cli compile `
      --fqbn $Fqbn `
      --build-path $BuildPath `
      --output-dir $BuildDir `
      $ProjectDir

    if ($LASTEXITCODE -eq 0) {
        Write-Host "=== OK ==="
    } else {
        Write-Host "=== FAIL ==="
    }
    Write-Host ""
}

# Check for arduino-cli
if (-not (Get-Command "arduino-cli" -ErrorAction SilentlyContinue)) {
    Write-Error "arduino-cli is required but not found in PATH. Please install it and add to your PATH."
    exit 1
}

Write-Host "Watching $ProjectDir for source changes..."
Write-Host "FQBN=$Fqbn (override with: .\watch.ps1 -Fqbn arduino:renesas_uno:minima)"
Write-Host "Press Ctrl+C to stop"
Write-Host ""

Compile-Sketch

if ($Once) {
    exit 0
}

# Setup FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $ProjectDir
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

$lastCompiled = [DateTime]::MinValue

while ($true) {
    # WaitForChanged returns a watcher change result. Timeout is set to 1000ms
    # to allow the while loop to periodically check for interrupt signals (Ctrl+C).
    $change = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::Changed -or [System.IO.WatcherChangeTypes]::Created, 1000)
    if ($change.TimedOut) {
        continue
    }

    $fullPath = Join-Path $ProjectDir $change.Name
    if ($fullPath -eq $SketchFile) {
        $now = [DateTime]::Now
        if (($now - $lastCompiled).TotalSeconds -lt $DebounceSeconds) {
            continue
        }
        $lastCompiled = $now
        Write-Host "=== Changed: $($change.Name) ==="
        Compile-Sketch
    }
}
