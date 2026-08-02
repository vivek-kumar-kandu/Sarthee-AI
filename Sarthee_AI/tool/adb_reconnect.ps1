# Reconnects ADB and prepares a physical Android device for Flutter + local backend.
# Usage: .\tool\adb_reconnect.ps1

Write-Host "Restarting ADB server..."
adb kill-server
Start-Sleep -Seconds 2
adb start-server
Start-Sleep -Seconds 2

Write-Host "`nConnected devices:"
adb devices

$offline = adb devices | Select-String "offline"
if ($offline) {
    Write-Host "`nDevice still offline. On your phone:" -ForegroundColor Yellow
    Write-Host "  1. Unplug and replug the USB cable"
    Write-Host "  2. Set USB mode to File transfer / MTP"
    Write-Host "  3. Re-allow USB debugging if prompted"
    Write-Host "  4. Run this script again"
    exit 1
}

Write-Host "`nSetting up port reverse for local backend (port 5000)..."
adb reverse tcp:5000 tcp:5000

Write-Host "`nADB ready." -ForegroundColor Green
Write-Host "Physical device run:"
Write-Host "  flutter run --dart-define=API_BASE_URL=http://127.0.0.1:5000/api/v1"
Write-Host "Emulator run:"
Write-Host "  flutter run"
exit 0
