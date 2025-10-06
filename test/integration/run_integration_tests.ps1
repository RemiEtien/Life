# Integration Tests Runner for Lifeline (Windows PowerShell)
# This script sets up the Firebase Emulator and runs all integration tests

param(
    [Parameter(Position=0)]
    [ValidateSet('auth', 'memory', 'premium', 'functions', 'all', 'coverage')]
    [string]$TestSuite = 'all'
)

$ErrorActionPreference = "Stop"

Write-Host "=== Lifeline Integration Tests Runner ===" -ForegroundColor Green
Write-Host ""

# Check if Firebase CLI is installed
try {
    $firebaseVersion = firebase --version 2>&1
    Write-Host "✓ Firebase CLI installed: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: Firebase CLI is not installed" -ForegroundColor Red
    Write-Host "Install it with: npm install -g firebase-tools"
    exit 1
}

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "✓ Flutter installed: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: Flutter is not installed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "1. Checking Firebase project configuration..." -ForegroundColor Yellow

if (-not (Test-Path "firebase.json")) {
    Write-Host "Error: firebase.json not found" -ForegroundColor Red
    Write-Host "Run: firebase init emulators"
    exit 1
}

Write-Host "✓ Firebase project configured" -ForegroundColor Green
Write-Host ""

Write-Host "2. Installing Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "✓ Dependencies installed" -ForegroundColor Green
Write-Host ""

Write-Host "3. Starting Firebase Emulators..." -ForegroundColor Yellow

# Kill any existing emulator instances
Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*firebase*emulators*"} | Stop-Process -Force
Start-Sleep -Seconds 2

# Start emulators in background
$emulatorJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    firebase emulators:start --only auth,firestore,storage
}

# Wait for emulators to start
Write-Host "Waiting for emulators to initialize..."
Start-Sleep -Seconds 15

# Check if emulators are running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4000" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Emulators running" -ForegroundColor Green
    Write-Host "  - Auth Emulator: http://localhost:9099"
    Write-Host "  - Firestore Emulator: http://localhost:8080"
    Write-Host "  - Storage Emulator: http://localhost:9199"
    Write-Host "  - Emulator UI: http://localhost:4000"
    Write-Host ""
} catch {
    Write-Host "Error: Emulators failed to start" -ForegroundColor Red
    Stop-Job $emulatorJob
    Remove-Job $emulatorJob
    exit 1
}

# Cleanup function
function Cleanup {
    Write-Host ""
    Write-Host "Stopping Firebase Emulators..." -ForegroundColor Yellow
    Stop-Job $emulatorJob -ErrorAction SilentlyContinue
    Remove-Job $emulatorJob -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "✓ Cleanup complete" -ForegroundColor Green
}

# Register cleanup on script exit
Register-EngineEvent PowerShell.Exiting -Action { Cleanup }

try {
    Write-Host "4. Running Integration Tests..." -ForegroundColor Yellow
    Write-Host ""

    switch ($TestSuite) {
        'auth' {
            Write-Host "Running Authentication Flow Tests..." -ForegroundColor Cyan
            flutter test test/integration/auth_flow_integration_test.dart
        }
        'memory' {
            Write-Host "Running Memory CRUD & Sync Tests..." -ForegroundColor Cyan
            flutter test test/integration/memory_crud_sync_integration_test.dart
        }
        'premium' {
            Write-Host "Running Premium Purchase Tests..." -ForegroundColor Cyan
            flutter test test/integration/premium_purchase_integration_test.dart
        }
        'functions' {
            Write-Host "Running Cloud Functions Tests..." -ForegroundColor Cyan
            Write-Host "Note: Some tests may be skipped if functions are not deployed" -ForegroundColor Yellow
            flutter test test/integration/cloud_functions_integration_test.dart
        }
        'all' {
            Write-Host "Running All Integration Tests..." -ForegroundColor Cyan
            flutter test test/integration/ --exclude-tags=requires-functions
        }
        'coverage' {
            Write-Host "Running All Integration Tests with Coverage..." -ForegroundColor Cyan
            flutter test test/integration/ --exclude-tags=requires-functions --coverage

            Write-Host ""
            Write-Host "Generating HTML coverage report..." -ForegroundColor Yellow

            # Check if genhtml is available (requires Perl + lcov on Windows)
            try {
                genhtml coverage/lcov.info -o coverage/html
                Write-Host "✓ Coverage report generated: coverage/html/index.html" -ForegroundColor Green
            } catch {
                Write-Host "Warning: genhtml not available. Install lcov for HTML reports." -ForegroundColor Yellow
                Write-Host "Coverage data available at: coverage/lcov.info" -ForegroundColor Yellow
            }
        }
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=== All Tests Passed! ===" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "=== Tests Failed ===" -ForegroundColor Red
        Write-Host ""
        throw "Tests failed with exit code $LASTEXITCODE"
    }

} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    Cleanup
    exit 1
}

# Keep emulators running for manual inspection
Write-Host "Emulator UI is still running at http://localhost:4000" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop emulators and exit" -ForegroundColor Yellow
Write-Host ""

# Wait for user to stop
Wait-Job $emulatorJob

Cleanup
