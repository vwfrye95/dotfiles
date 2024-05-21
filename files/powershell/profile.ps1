# Oh My Posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression

# Posh Git
Import-Module posh-git

# PoSh Fuck
Import-Module PoShFuck

# Functions
## Git - These functions allow for management of Git Repositories
function Reset-AllRepositories() {
  $RepositoryDirectories = Get-AllRepositories

  foreach ($r in $RepositoryDirectories) {
    git init $r.FullName
  }
}

function Get-AllRepositories() {
  return (Get-ChildItem $env:SOURCE_ROOT -Attributes Directory+Hidden -ErrorAction SilentlyContinue -Filter '.\.git' -Recurse).Parent
}

function Clear-RepositoryBranches() {
  $branches = git branch --list | Select-String -Pattern '^\*' -NotMatch | Select-String -Pattern 'main' -NotMatch

  foreach ($b in $Branches) {
    $Branch = $b.Line.Trim()
    git branch -D $Branch
  }
}

## Docker - These functions include general Docker commands that might be useful
function Clear-Docker { docker image prune -a --filter 'until=12h'; docker system prune }


## Java - These functions allow for JDK version management
function Reset-JavaHome() {
  $env:JAVA_HOME = $env:JDK_21_HOME
  Write-Output "The JAVA_HOME environment variable is now set to $env:JAVA_HOME."
}

function Set-JavaHome([int] $Version) {
  $CurrentJdk = $env:JAVA_HOME
  
  if (-NOT $Version) {
    Reset-JavaHome
    return
  }
  
  switch ($Version) {
    17 {
      if (-NOT (Test-Path -Path $env:JDK_17_HOME)) {
        Write-Output "No JDK configured for version $PSItem... Aborted."
        break
      }

      $CurrentJdk = $env:JDK_17_HOME
      break
    }
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

## Personal projects
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
  Set-Location $env:SRC_MSG
}

Set-Alias -Name slvf -Value Set-LocationToVictorFryeRepositories
Set-Alias -Name slvfdf -Value Set-LocationToVictorFryeDotfiles
Set-Alias -Name slvfcom -Value Set-LocationToVictorFryeDotCom
Set-Alias -Name slmsg -Value Set-LocationToMicrosoftGraveyard

## Miscellaneous
function Get-Path() {
  Write-Output $Env:PATH.Split(';')
}

Set-Alias -Name code -Value code-insiders

# Environment Variables
$env:SRC_VFDF = Join-Path $env:REPOS_VF 'Dotfiles'
$env:SRC_VFCOM = Join-Path $env:REPOS_VF 'DotCom'
$env:SRC_MSG = Join-Path $env:REPOS_VF 'MicrosoftGraveyard'
