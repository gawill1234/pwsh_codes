#
#  The functions have been created to be an entire step in 
#  the deploy process.  So we have:
#     stop_pool -- stop IIS application pool
#     start_pool -- start IIS application pool
#     copy_app -- copy the published app to the target directory
#     copy_configs -- copy the app config files to the target directory
#     backup_current_app -- backup the existing (pre-deploy) app
#     publish_the_application -- build the app to the publish directory
#     git_checkout_config -- checkout the needed config files version
#     git_checkout_application -- checkout the application version
#     get_project_directory -- select the directory where the repo is
#     get_application_pool -- select the pool where the app is running
#     clearBackups -- Get rid of excess backups
#

#
#  Checkout the version of the config files that has been
#  selected.
#
function git_clone_repo {
   param ($PathBase, $repo)

   if (!(Test-Path -Path $PathBase)) {
      #
      #   Get our current location
      #
      $yy = (Get-Location).Path

      $xx = Split-Path $PathBase -Parent

      #
      #   Create the directory if it does not exist
      #
      $build = buildthepath -directoryPath $xx
      if ($build -eq 0) {
         Write-Host $xx "was not created.  Clone failed." -f Red
         return 0
      }

      #
      #   Go to where we will clone the repo to
      #
      Set-Location -Path $xx

      git clone $repo
      $res = $?

      #
      #   Return to where we started
      #
      Set-Location -Path $yy

      if (-not $res) {
         Write-Host "Directory clone failed" -f Red
         Write-Host "Attempted $repo" -f Red
         throw
      }
   }

   return 1
}

#
#   This functions exists for the simple reason of 
#   keeping the conditional out of an env file.
#
function doweclone {
   param ($PathBase, $repo)

   $success = 1
   if (!(Test-Path -Path $PathBase)) {
      $success = git_clone_repo -PathBase $PathBase -repo $repo
   }

   return $success
}

#
#   Checkout the version of the config files we want.
#   Version = branch in these cases.  If the selected
#   branch if "ASIS_LOCAL", skip this.  That branch means
#   use the config files supplied with the application
#   itself.
#
function git_checkout_config {
   param ($ConfigPath, $branch)

   # Navigate to the project directory
   Set-Location -Path $ConfigPath

   # Checkout the proper config branch
   Write-Host "`n`n==================================================================================================="
   Write-Host "Fetching Origin of eCMSConfigFiles and checking out branch"
   Write-Host "==================================================================================================="
   try {
      git fetch origin
      if ($branch -eq "") {
         $thing = git branch -r --format='%(refname:short)'
         $branch = echo $thing ASIS_LOCAL | ForEach-Object { $_ -replace '^origin/', '' } | Sort-Object | Out-GridView -Title "Select a Git Branch" -OutputMode Single
      }
      if ($branch -eq "ASIS_LOCAL") {
         #
         #   If the branch is set to "ASIS_LOCAL", there is
         #   nothing to do.  We are using the config files
         #   STORED WITH THE PROJECT.  So just return.
         #
         return "ASIS_LOCAL"
      } else {
         if ($branch) { 
            Write-Host "Checking out the $branch branch..." 
            #
            #  The "$ignore" is due to a powershell idiosyncracy
            #  If you don't capture the command(s) output, that
            #  output is returned with the return value you want,
            #  which is generally pretty messy.
            #  The captured output still goes to console; weird.
            #
            $ignore = git reset
            $ignore = git checkout $branch 
            $res = $?
            if (-not $res) {
               Write-Host "Configuration branch checkout failed" -f Red
               throw
            }
            $ignore = git pull
         }
      }
   } catch {
      Write-Output "Configuration Checkout Error:  $_"
      throw
   }

   return $branch
}

#
#   Checkout the version of the application that has been
#   selected.
#   If "ASIS" is the selected branch, do not update the
#   repository at all.  Use it as it sits (ASIS).
#
function git_checkout_application {
   param ($ProjectPath, $branch)

   # Navigate to the project directory
   Set-Location -Path $ProjectPath

   # Checkout the proper app branch
   Write-Host "`n`n==================================================================================================="
   Write-Host "Fetching Origin of Application and checking out branch"
   Write-Host "==================================================================================================="

   try {
      git fetch origin
      if ($branch -eq "") {
         $thing = git branch -r --format='%(refname:short)'
         $branch = echo $thing ASIS | ForEach-Object { $_ -replace '^origin/', '' } | Sort-Object | Out-GridView -Title "Select a Git Branch" -OutputMode Single
      }
      if ($branch -eq "ASIS") {
         #
         #   If the branch is set to "ASIS", there is
         #   nothing to do.  We want the project AS IT
         #   CURRENTLY EXISTS.  So change nothing.  Just
         #   return.
         #
         return "ASIS"
      } else {
         if ($branch) { 
            Write-Host "Checking out the $branch branch..." 
            #
            #  The "$ignore" is due to a powershell idiosyncracy
            #  If you don't capture the command(s) output, that
            #  output is returned with the return value you want,
            #  which is generally pretty messy.
            #  The captured output still goes to console; weird.
            #
            $ignore = git restore .
            $ignore = git reset
            $ignore = git checkout $branch 
            $res = $?
            if (-not $res) {
               Write-Host "Application branch checkout failed" -f Red
               throw
            }
            $ignore = git pull
         }
      }
   } catch {
      Write-Output "Application Checkout Error:  $_"
      throw
   }

   return $branch
}

#
#   Within a repository, get the branch
#   we are on.
#
function git_current_branch {
   param ($ConfigPath)

   #
   #   Get and save the starting location
   #
   $startPath = (Get-Location).Path

   #
   #   Go to the git directory we care about
   #
   Set-Location -Path $ConfigPath

   $where = git status -b -s -u no
   $where = $where.replace("...", ":")
   $where = $where.replace("#", "")
   $where = $where.replace(" ", "")
   $where = $where.split(":")[0]

   #
   #   Return to starting location
   #
   Set-Location -Path $startPath

   return $where
}

#
#   Are we on the branch we want to be on?
#
#   Example call:
#      git_correct_branch -ConfigPath $ConfigPath \
#                         -desiredBranch "cr/Aquilent-Oct7.07a-319068-GW"
#
function git_correct_branch {
   param ($ConfigPath, $desiredBranch)

   if ($desiredBranch -eq "ASIS") {
      return 1
   } elseif ($desiredBranch -eq "ASIS_LOCAL") {
      return 1
   } else {
      $where = git_current_branch -ConfigPath $ConfigPath
   }

   if ($where -eq $desiredBranch) {
      Write-Host "Expected branch $desiredBranch, on branch $where" -f Green
      return 1
   }

   Write-Host "Expected branch $desiredBranch, on branch $where" -f Red

   return 0
}

