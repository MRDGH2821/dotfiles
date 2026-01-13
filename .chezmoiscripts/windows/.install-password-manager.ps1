if (Get-Command keepassxc.exe -ErrorAction SilentlyContinue) {
  Write-Output "KeePassXC is already installed. Skipping"
  exit
}

winget install -e --id KeePassXCTeam.KeePassXC
function Add-ToPath {
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $dir
  )

  $dir = (Resolve-Path $dir)

  $path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
  if (!($path.Contains($dir))) {
    # backup the current value
    "PATH=$path" | Set-Content -Path "$env:USERPROFILE/path.env"
    # append dir to path
    [Environment]::SetEnvironmentVariable("PATH", $path + ";$dir", [EnvironmentVariableTarget]::Machine)
    Write-Output "Added $dir to PATH"
    return
  }
  Write-Error "$dir is already in PATH"
}
Add-ToPath "C:\Program Files\KeePassXC"

Write-Output "KeePassXC installed"
