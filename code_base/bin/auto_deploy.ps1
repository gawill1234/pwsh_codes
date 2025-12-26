#! pwsh
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
#
#  The above required functions are in lib/myFunctions.ps1 and are
#  "." sourced to this program.
#
#  The params are as follows:
#     SaveFileName   -- save the answers to run questions to that file
#     ReadFileName   -- use the file to answer the run questions rather than
#                       answering them individually
#     AllDirectory   -- the directory where the question/config files exist
#                       to do mulitple deploys
#     Build          -- Should we do the build.  "Yes" or "No".  Default is
#                       "Yes".
#     SetPublishPath -- Set a different publish path than the default for
#                       the product to be installed.
#
#  auto_deploy.ps1 -SaveFileName myfile.ps1
#     Save all answers to deploy questions asked by the script to file
#     named myfile.ps1
#  auto_deploy.ps1 -ReadFileName myfile.ps1
#     Do not ask the deploy questions.  Use file myfile.ps1 to supply the
#     answers to all of the questions
#  auto_deploy.ps1 -AllDirectory ALL
#     Go to directory ALL and use each of the files there to perform the
#     deploy of the app within each of the files.  Be aware: if you have
#     2 different copies of application install data, both will be done.
#     If they both deploy to the same location, the second will overwrite
#     the first.
#  auto_deploy.ps1
#     Runs by asking for each item needed to deploy individually.  The 
#     deploy is done, but the data for the deploy is not saved.
#
param ([string]$SaveFileName = "",
       [string]$ReadFileName = "",
       [string]$AllDirectory = "",
       [string]$SetPublishPath = "",
       [string]$BuildMode = "",
       [string]$UseLink = "yes",
       [string]$Build = "")

[int]$redo = 1

#
#   The "Deploy" subdirectory is part of
#   the path where this script resides.  If it
#   changes, we'll need to alter what this is
#   looking for.
#
function findOurRoot {

   # $xx = (Get-Location).Path
   $xx = $PSScriptRoot

   if ($xx.EndsWith("Deploy")) {
      return $xx
   } else {
      if ($xx.Contains("Deploy")) {
         do {
            $xx = Split-Path $xx -Parent
         } until ($xx.EndsWith("Deploy"))
         return $xx
      }
   }

   return "NotFound"
}

#
#
function buildLine {

   $PubFile = ""

   if (!(Test-Path -Path $ConfigPath)) {
      $success = doweclone -PathBase $ConfigPath -repo $repo
   }
   git config --global --add safe.directory $ConfigPath

   #
   # Checkout the version of the application we need
   #
   $right_branch = 0
   $count = 0
   do {
      $count = $count + 1
      if ($count -ge 4) {
         Write-Host "Setting application repo to desired branch failed" -f Red
         Set-Location -Path $ScriptPath
         exit 1
      }
      $appbranch = git_checkout_application -ProjectPath $ProjectPath -branch $appbranch
      $right_branch = git_correct_branch -ConfigPath $ProjectPath -desiredBranch $appbranch
   } until ($right_branch -eq 1)

   runUpdateVersion -path $ProjectPath

   if ($SetPublishPath -eq "Yes") {
      $PublishProfile = "autoPubFile"
      $PubFile = "autoPubFile.pubxml"
      $PublishPath = get_publish_location -PublishPath $PublishPath
      $ProfileFilePath = buildProfilePath -oldProjPath $ProjectPath -newName $PubFile 
      if ($ProfileFilePath -ne "") {
         newPublishProfile -nameIt $ProfileFilePath -newPubLoc $PublishPath -pubFileName $ProfileFilePath
      }
   }

   #
   #   Do the build.  No conditions.  After all,
   #   the only thing we are doing is the build.
   #
   publish_the_application -PublishPath $PublishPath -ProjectPath $ProjectPath -UseDotNet $usedotnet

   return
}
#
#   The common code for all types of deploys
#   (single, saved, all).
#
function mainLine {
   param ($zipfile, $doVerify)

   $PubFile = ""

   . $ScriptPath/app_env_files/ecmsconfig_env.ps1
   if (!(Test-Path -Path $ConfigPath)) {
      $success = doweclone -PathBase $ConfigPath -repo $repo
   }
   git config --global --add safe.directory $ConfigPath

   #
   # Checkout the version of the config files we need
   #
   $right_branch = 0
   $count = 0
   do {
      $count = $count + 1
      if ($count -ge 4) {
         Write-Host "Setting config file repo to desired branch failed" -f Red
         Set-Location -Path $ScriptPath
         exit 1
      }
      $cfgbranch = git_checkout_config -ConfigPath $ConfigPath -branch $cfgbranch
      $right_branch = git_correct_branch -ConfigPath $ConfigPath -desiredBranch $cfgbranch
   } until ($right_branch -eq 1)

   #
   # Checkout the version of the application we need
   #
   $right_branch = 0
   $count = 0
   do {
      $count = $count + 1
      if ($count -ge 4) {
         Write-Host "Setting application repo to desired branch failed" -f Red
         Set-Location -Path $ScriptPath
         exit 1
      }
      $appbranch = git_checkout_application -ProjectPath $ProjectPath -branch $appbranch
      $right_branch = git_correct_branch -ConfigPath $ProjectPath -desiredBranch $appbranch
   } until ($right_branch -eq 1)

   runUpdateVersion -path $ProjectPath

   if ($SetPublishPath -eq "Yes") {
      $PublishProfile = "autoPubFile"
      $PubFile = "autoPubFile.pubxml"
      $PublishPath = get_publish_location -PublishPath $PublishPath
      $ProfileFilePath = buildProfilePath -oldProjPath $ProjectPath -newName $PubFile 
      if ($ProfileFilePath -ne "") {
         newPublishProfile -nameIt $ProfileFilePath -newPubLoc $PublishPath -pubFileName $ProfileFilePath
      }
   }

   Set-Location -Path $ScriptPath

   if ($doVerify -eq 1) {
      $xxx = VerifySelections
      if ($xxx -eq 1) {
         return 1
      }
   }

   #
   #   Save the selections to a config/env file to be reused later
   #
   if ($SaveFileName -ne "") {
      save_file -SaveFileName $SaveFileName -FilePath $ScriptPath
      # . $ScriptPath\helper_files\dump_data.ps1
   }

   # Publish the .NET Project
   if ($Build -eq "Yes") {
      publish_the_application -PublishPath $PublishPath -ProjectPath $ProjectPath -UseDotNet $usedotnet
   } else {
      Write-Host "No build is being done. Existing build being used." -ForegroundColor Yellow
   }

   if ($zipfile -eq 1) {
      if ($cfgbranch -ne "ASIS_LOCAL") {
         copy_configs -ConfigAppPath $ConfigAppPath -RemotePath $PublishPath
      }
      zip_not_deploy -PublishPath $PublishPath -application $application
   } else {

      # Backup the existing remote folder/current application
      backup_current_app -RemotePath $RemotePath

      # Stop the IIS App Pool
      stop_pool -AppPoolName $AppPoolName -RemoteServer $RemoteServer

      #  Copy the published application to the pool path
      copy_app -PublishPath $PublishPath -RemotePath $RemotePath -CfgBranch $cfgbranch

      #  Update the configuration files for this install
      if ($cfgbranch -ne "ASIS_LOCAL") {
         copy_configs -ConfigAppPath $ConfigAppPath -RemotePath $RemotePath
      }

      # Start the IIS App Pool
      start_pool -AppPoolName $AppPoolName -RemoteServer $RemoteServer
   }

   return 0
}

#
#
function doBuildOneOnly {

   $myServer = "BuildOnly"
   $RemoteServer = "BuildOnly"

   $application = SelectApplication -myEnv $myServer

   $appenvfile = returnAppEnvFile -application $application -ourroot $ScriptPath

   if ($appenvfile -eq "NotFound") {
      Write-Host "Installation of " $application " applications not yet implemented" -ForegroundColor Red
      exit 1
   } else {
      Write-Host "Using setup file: " $appenvfile -f Green
      . $appenvfile
   } 

   #
   #  Single application build only selection
   #
   buildLine

   return 1

}
#
#   Select everything for deploying a single
#   application.  Then call to mainLine.
#
function doSingle {
   # param ([int]$redo)

   $myServer = SelectRemoteServer
   $RemoteServer = getRemoteAddress -myServer $myServer
   $whichcfg = getConfigFileLoc -myServer $myServer
   $application = SelectApplication -myEnv $myServer

   #
   #   For the moment, the needed variables are hardcoded
   #   in each of the env files specific to the application.
   #   It needs to be changes so those values can be changed
   #   on a per run basis.  Working on it ...
   #
   #   variables are:
   #      $ProjectPath - now selectable
   #      $PublishPath - now selectable
   #      $RemoteServer
   #      $RemotePath
   #      $ConfigPath
   #      $ConfigAppPath
   #      $AppPoolName
   #

   $appenvfile = returnAppEnvFile -application $application -ourroot $ScriptPath

   if ($appenvfile -eq "NotFound") {
      Write-Host "Installation of " $application " applications not yet implemented" -ForegroundColor Red
      exit 1
   } else {
      Write-Host "Using setup file: " $appenvfile -f Green
      . $appenvfile
   } 

   $zipfile = izitzipit -myServer $RemoteServer -zipfile $zipfile

   #
   #  Single application selection
   #
   $yyy = mainLine -zipfile $zipfile -doVerify 1

   if ($yyy -eq 0) {
      $redo = 0
      return
   }

   $redo = 1
   return

}

#
#   Cycle through all of the install files
#   for each of the products saved in the all
#   directory.
#
function doAll {
   param ($AllDirectory)

   #
   #  You may select "ALL" as the app to deploy from the displayed
   #  list/menu.  If you select, it will ask for the "ALL" directory
   #  where the config/deploy files exist.
   #
   if ($AllDirectory -eq $null -or $AllDirectory -eq "") {
      $DefaultDir = "$ScriptPath\ALL"
      $AllDirectory = get_project_directory -default_path "$DefaultDir" -which 2
   }

   $zipfile = izitzipit -myServer $RemoteServer -zipfile $zipfile

   #
   #  Run "ALL" selections
   #  Does the actual cycling through the file list.
   #
   runAll -AllDirectory $AllDirectory -zipfile $zipfile

   return 0
}

# Variables
#   For the moment, we want this path.  But we can do it without
#   hardcoding it.
#      $ScriptPath = "D:\AutoDeploy\Scripts"
# $ScriptPath = (Get-Location).Path
$ScriptPath = findOurRoot

Write-Host "ScriptPath: " $ScriptPath

if ($ScriptPath -eq "NotFound") {
   Write-Host "Curret root directory may be missing sub-trees" -f Red
   Write-Host 'The path must contain a "Deploy" branch' -f Red
   exit 1
}

#
#   This has been made global for the stupidest of reasons.
#   Powershell likes to dump function output in such a way
#   that it gets picked up by any local variables that are
#   returned to the calling function.  So you may expect
#   the value to be an integer, but due to a powershell
#   stupid, it is that integer PLUS a string of all the 
#   output from the function.  Makeing it global gets
#   around that.  I have fixed that for now.  But any future
#   code supporter might not be aware of that, uh,
#   limitation.  So, basically making easier for others to
#   maintain.
#

. $ScriptPath/lib/myFunctions.ps1
. $ScriptPath/lib/poolactions.ps1
. $ScriptPath/lib/gitactions.ps1
. $ScriptPath/lib/appenvactions.ps1

if (Test-Path -Path $ScriptPath/app_env_files/global_env.ps1) {
   . $ScriptPath/app_env_files/global_env.ps1
}

$admincheck = amiadministrator
if ($admincheck -eq 0) {
   Write-Host "Application must be running as Administrator, Exiting" -f Red
   Write-Host "Restart Powershell in Run as Administrator mode and rerun auto_deploy.ps1" -f Red
   exit 1
}

Write-Host "`n`n===================================================================================================`n`n`n Auto Deploy eCMS `n`n`n==================================================================================================="

if ($SaveFileName -ne "") {
   Write-Host "Saving configuration data to: $SaveFileName"
}

if ($Build -eq "") {
   $Build = "Yes"
}

if ($SetPublishPath -eq "") {
   $SetPublishPath = "No"
}

if ($Build -eq "Yes") {
   Write-Host "New build is being done."
} else {
   Write-Host "No build is being done.  Copying from existing publish location."
}

$appbranch = ""
$cfgbranch = ""

#
#  $all is a flag.  
#  0 means, don't do "ALL"
#  1 means do "ALL"
#
#  $zipfile is a flag.  
#  0 means, deploy normally to the remote server
#  1 means create a zipfile rather than deploy
#
$all = 0
$zipfile = 0
$usedotnet = 1

if ($ReadFileName -ne "") {
   $ReadFileName = InputFileIsGood -FileName $ReadFileName
   if ($ReadFileName -eq "") {
      exit 1
   }
   Write-Host "###############################################"
   Write-Host "Reading from:  $ReadFileName" -f Green
   . $ReadFileName
   Write-Host "Using these settings for the deployment"
   dump_file_data
   Write-Host "###############################################"
} else {
   if ($AllDirectory -ne "") {
      $AllDirectory = InputDirectoryIsGood -DirName $AllDirectory
      if ($AllDirectory -eq "") {
         exit 1
      }
      Write-Host "Using directory/folder:  $AllDirectory" -f Green
      $all = 1
   }
} 

Write-Host "`n`n==================================================================================================="

Write-Host "`n`n" $application "Auto Deploy eCMS"

Write-Host "`n`n==================================================================================================="

if ($BuildMode -eq "BuildOnly") {
   doBuildOneOnly
} else {
   if ($all -eq 1) {
      #
      #  Run "ALL" selections
      #
      doAll -AllDirectory $AllDirectory
   } elseif ($ReadFileName -ne "") {

      $zipfile = izitzipit -myServer $RemoteServer -zipfile $zipfile
      #
      #  Single application selection
      #
      $zzz = mainLine -zipfile $zipfile -doVerify 0

   } else {
      #
      #  Single application selection
      #
      while ($redo -eq 1) {
        $redo = 0
        # $redo = doSingle -redo 0
        doSingle
        Write-Host "REDO:  $redo" -f magenta
      }
      # $redo = doSingle
   }
}

# Navigate to the project directory
Set-Location -Path $ScriptPath
if ($BuildMode -eq "BuildOnly") {
   Write-Host "`n`nBuild, such as it is, completed!`n" -ForegroundColor Green
} else {
   Write-Host "`n`nDeployment completed successfully!`n" -ForegroundColor Green
}

exit 0
