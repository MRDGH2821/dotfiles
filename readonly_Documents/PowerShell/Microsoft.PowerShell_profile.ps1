# Oh my posh random theme initializer
# Select a random theme
$theme = Get-ChildItem $env:UserProfile\AppData\Local\Programs\oh-my-posh\themes\ | Get-Random
Write-Output $theme.name
# Set the theme
oh-my-posh --init --shell pwsh --config $theme.FullName | Invoke-Expression

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Fast node Manager
fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression

# Zoxide
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })

# Aliases
Remove-Item Alias:cat -Force
Set-Alias -Name cat -Value bat

# McFly

Invoke-Expression -Command $(mcfly init powershell | out-string)
