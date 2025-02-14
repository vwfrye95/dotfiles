# MARK: Oh My Posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\azure-cloud-native.omp.json" | Invoke-Expression

# MARK: Posh Git
Import-Module posh-git

# MARK: Git - These functions allow for management of all Git Repositories
function Reset-AllRepositories() {
  $RepositoryDirectories = Get-AllRepositories
  
  foreach ($Repo in $RepositoryDirectories) {
    git init $Repo.FullName
  }
}
  
function Get-AllRepositories() {
  return (Get-ChildItem $env:DEVDRIVE -Attributes Directory+Hidden -ErrorAction SilentlyContinue -Filter '.\.git' -Recurse).Parent
}

function Clear-RepositoryBranches() {
  git branch --list `
  | Select-String -Pattern '^\*' -NotMatch `
  | Select-String -Pattern 'main' -NotMatch `
  | ForEach-Object { git branch -D $_.Line.Trim() }
}

# MARK: Java - These functions allow for JDK version management
function Reset-JavaHome() {
  $env:JAVA_HOME = $env:JDK_21
  Write-Output "The JAVA_HOME environment variable is now set to $env:JAVA_HOME."
}

function Set-JavaHome([int] $Version) {
  $CurrentJdk = $env:JAVA_HOME
  
  if (-NOT $Version) {
    Reset-JavaHome
    return
  }
  
  switch ($Version) {
    21 {
      if (-NOT (Test-Path -Path $env:JDK_21_HOME)) {
        Write-Output "No JDK configured for version $PSItem... Aborted."
        break
      }

      $CurrentJdk = $env:JDK_21_HOME
      break
    }
    Default { Write-Output "No JDK configured for version $PSItem... Aborted." }
  }

  if ($env:JAVA_HOME -NE $CurrentJdk) {
    $env:JAVA_HOME = $CurrentJdk
    Write-Output "The JAVA_HOME environment variable is now set to $env:JAVA_HOME."
  }
}

Set-Alias -Name sjh -Value Set-JavaHome
Set-Alias -Name rsjh -Value Reset-JavaHome

Set-Alias -Name code -Value code-insiders

function ConvertTo-Sha256Hash([string] $Value) {
  $HashedBytes = [System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($Value))

  return [System.BitConverter]::ToString($HashedBytes).Replace('-', '').ToLower()
}

Set-Alias -Name cthash -Value ConvertTo-Sha256Hash

# MARK: Personal Projects
function Set-LocationToVictorFryeRepositories {
  Set-Location $env:REPOS_VF
}

function Set-LocationToVictorFryeDotfiles {
  Set-Location $env:SRC_VFDF
}

function Set-LocationToVictorFryeDotCom {
  Set-Location $env:SRC_VFCOM
}

function Set-LocationToMicrosoftGraveyard {
  Set-Location $env:SRC_VFMSG
}

function Set-LocationToMockingMirror {
  Set-Location $env:SRC_VFMIR
}

Set-Alias -Name slvf -Value Set-LocationToVictorFryeRepositories
Set-Alias -Name slcom -Value Set-LocationToVictorFryeDotCom
Set-Alias -Name slmsg -Value Set-LocationToMicrosoftGraveyard
Set-Alias -Name slmir -Value Set-LocationToMockingMirror

function Start-VictorFryeDotComApp {
  dotnet run --project "$env:SRC_VFCOM/src/AppHost/AppHost.csproj"
}

function Start-MicrosoftGraveyardApp {
  dotnet run --project "$env:SRC_VFMSG/src/AppHost/AppHost.csproj"
}

function Start-MockingMirrorApp {
  dotnet run --project "$env:SRC_VFMIR/src/AppHost/AppHost.csproj"
}

Set-Alias -Name sacom -Value Start-VictorFryeDotComApp
Set-Alias -Name samsg -Value Start-MicrosoftGraveyardApp
Set-Alias -Name samir -Value Start-MockingMirrorApp

# MARK: Path
function Get-Path() {
  Write-Output $Env:PATH.Split(';')
}

# MARK: Environment Variables
$env:SRC_VFDOT = Join-Path $env:REPOS_VF 'Dotfiles'
$env:SRC_VFCOM = Join-Path $env:REPOS_VF 'DotCom'
$env:SRC_VFMSG = Join-Path $env:REPOS_VF 'MicrosoftGraveyard'
$env:SRC_VFMIR = Join-Path $env:REPOS_VF 'MockingMirror'

# Mark: Inshellisense

# if ( Test-Path "$env:HOME/.inshellisense/pwsh/init.ps1" -PathType Leaf ) { . $env:HOME/.inshellisense/pwsh/init.ps1 } 
