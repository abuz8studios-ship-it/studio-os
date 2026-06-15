$ErrorActionPreference = "Stop"

$wslDistro = "Ubuntu"
$studioRoot = ".\StudioOS"
$mvpUrl = "http://127.0.0.1:29212"
$routerUrl = "http://127.0.0.1:29213"

Start-Process -WindowStyle Normal -FilePath "wsl.exe" -ArgumentList @(
  "-d", $wslDistro, "bash", "-lc",
  "exec /mnt/e/ABU/StudioOS/bin/studio-mvp-server.sh"
)

Start-Process -WindowStyle Normal -FilePath "wsl.exe" -ArgumentList @(
  "-d", $wslDistro, "bash", "-lc",
  "exec /mnt/e/ABU/StudioOS/bin/studio-router-server.sh"
)

$deadline = (Get-Date).AddSeconds(20)
$mvpUp = $false
$routerUp = $false
while ((Get-Date) -lt $deadline) {
  try {
    $null = Invoke-WebRequest -UseBasicParsing "$mvpUrl/api/health" -TimeoutSec 2
    $mvpUp = $true
  } catch {}
  try {
    $null = Invoke-WebRequest -UseBasicParsing "$routerUrl/api/health" -TimeoutSec 2
    $routerUp = $true
  } catch {}
  if ($mvpUp -and $routerUp) { break }
  Start-Sleep -Seconds 1
}

Start-Process $routerUrl
Start-Process $mvpUrl
Start-Process -WindowStyle Normal -FilePath "wsl.exe" -ArgumentList @(
  "-d", $wslDistro, "bash", "-lc",
  "cd '/mnt/e/ABU/StudioOS' && /mnt/e/ABU/StudioOS/bin/studio-status.sh ; printf '\nPress Enter to close...'; read"
)

if (-not ($mvpUp -and $routerUp)) {
  Write-Host "Studio services did not confirm healthy within 20 seconds."
  Write-Host "Open the server windows to inspect the startup error."
}
