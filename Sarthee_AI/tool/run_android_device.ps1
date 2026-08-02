# Run on a USB-connected physical Android device (RMX3660 etc.)
# Usage: .\tool\run_android_device.ps1

Set-Location $PSScriptRoot\..

& "$PSScriptRoot\adb_reconnect.ps1"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter run --dart-define=API_BASE_URL=http://127.0.0.1:5000/api/v1 @args
