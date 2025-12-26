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
#   Use this later, maybe
#
function ranstringuln {
   param ($stlen = 10, $type = "ULN", $beginwlet = "true")

   $alphabet = @("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
                 "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
                 "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
                 "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
                 "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7",
                 "8", "9")

   $count = 0
   $word = ""

   $min = 0
   $max = 51

   if ($beginwlet -eq "true") {
      $letterval = Get-Random -Minimum $min -Maximum $max
      $letter = $alphabet[$letterval]
      $word = $word + $letter
      $count += 1
   }

   switch ($type) {
      "U" {
         $min = 0
         $max = 25
      }
      "UL" {
         $min = 0
         $max = 51
      }
      "ULN" {
         $min = 0
         $max = 61
      }
      "L" {
         $min = 26
         $max = 51
      }
      "LN" {
         $min = 26
         $max = 61
      }
      "N" {
         $min = 52
         $max = 61
      }
      default {
         $min = 0
         $max = 61
      }
   }

   while ($count -lt $stlen) {
      $letterval = Get-Random -Minimum $min -Maximum $max
      $letter = $alphabet[$letterval]
      $word = $word + $letter
      $count += 1
   }

   return $word
}

function fakeEmail {
   param ($maildomain = "va.gov")

   $value = ranstringuln -stlen 12

   $mailAddr = $value + "@" + $maildomain

   return $mailAddr
}

function checkDirectoryFiles {
   param ($path)

   $count = 0
   $conforms = 0
   $return_value = 0

   Get-ChildItem $path | ForEach-Object {
      $count = $count + 1
      switch -File ($_.FullName) {
          "*.ps1" {
              $conforms = $conforms + 1
              Write-Host "$($_.Name) is a powershell file."
          }
          "*.txt" {
              Write-Host "$($_.Name) is a text file."
          }
          "*.docx" {
              Write-Host "$($_.Name) is a Word document."
          }
          "*.xlsx" {
              Write-Host "$($_.Name) is an Excel workbook."
          }
          default {
              Write-Host "$($_.Name) is not a recognized file type."
          }
      }
   }

   if ($count -eq $conforms) {
      $return_value = 1
   }

   return $return_value
}

#
#   Stuff like this will be considered
#   to be valid
#
#   email = "abcdef@gmail.com"
#   email = "I.am.he@abc.va.gov"
#   phone = "4135551212"
#   phone = "(413)555-1212"
#   phone = "(413)5551212"
#   phone = "413-555-1212"
#   domain = "www.bbc.news.uk"
#   domain = "google.com"
#   domain = "herman.net"
#   domain = "herman.net.us"
#   
function isItValid {
   param ($name)

   $type = 0
   switch -Regex ($name) {
       "^\+?[0-9]{1,3}\s?[0-9]{7,14}$" {
           Write-Host "The input is a valid phone number."
           $type = 4
       }
       "^\+?[0-9]{1,3}-\s?[0-9]{1,3}-?[0-9]{1,4}$" {
           Write-Host "The input is a valid phone number."
           $type = 4
       }
       "^\(\+?[0-9]{1,3}\)\s?[0-9]{1,3}-?[0-9]{1,4}$" {
           Write-Host "The input is a valid phone number."
           $type = 4
       }
       "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" {
           Write-Host "The input is a valid email address."
           $type = $type + 1
       }
       "^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" {
           Write-Host "The input is a valid domain name."
           $type = $type + 2
       }
       default {
           Write-Host "The input is not recognized."
       }
   }

   return $type
}

function runUpdateVersion {
   param ($path)

   $ReturnPoint = (Get-Location).Path
   Set-Location -Path $path

   if (Test-Path -Path "./updateVersion.ps1") {
      Write-Host "updateVersion.ps1 running" -f Green
      . ./updateVersion.ps1
   } else {
      Write-Host "updateVersion.ps1 not found" -f Red
   }

   Set-Location -Path $ReturnPoint

   return
   
}

#
#   Test whether a folder/file is, in fact,
#   a link/symlink.
#
function Test-ReparsePoint {
   param ([string]$path)

   $file = Get-Item $path -Force -ea SilentlyContinue
   return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

# 
#  Do a recursive copy
#
function make-copy {
   param ($target, $link)

   #
   #   Once again, we don't care about the output.  But,
   #   if we don't capture it, it becomes a problem in
   #   other variables.  Like any variable we're returning.
   #   So, $farkle.  Probably should be $WeDontCare.
   #
   #   This does not include the -Force option to Copy-Item
   #   so if the file exists it will not be overwritten.
   #
   $farkle = Copy-Item $target -Destination $link -Recurse 2>&1
   $goob = $?

   if (-not $goob) {
      Write-Host "$link already exists" -f DarkRed
   } else {
      Write-Host "$link copied" -f DarkGreen
   }

   return $goob
}
# 
#  Create a symlink
#
function make-link {
   param ($target, $link)

   #
   #   Once again, we don't care about the output.  But,
   #   if we don't capture it, it becomes a problem in
   #   other variables.  Like any variable we're returning.
   #   So, $farkle.  Probably should be $WeDontCare.
   #
   $farkle = New-Item -Path $link -ItemType SymbolicLink -Value $target 2>&1
   $goob = $?

   if (-not $goob) {
      Write-Host "$link already exists" -f DarkRed
   } else {
      Write-Host "$link created" -f DarkGreen
   }

   return $goob
}

#
#   Make sure the file has the suffix
#   we supplied.
#
function checkfilesuffix {
   param ($FileName, $Suffix)

   if ($FileName.EndsWith($Suffix)) {
      return 1
   }

   return 0
}

#
#   Does the directory suit our needs?
#
function LinkOrDirectoryIsGood {
   param ($DirName)

   if (Test-Path -Path $DirName) {
      return 1
   }

   if (Test-ReparsePoint -path $DirName) {
      return 1
   }

   return 0
}

function checkandcopycomponents {
   param ($target, $link)

   $isit = LinkOrDirectoryIsGood -DirName $link

   if ($isit -eq 0) {
      Write-Host "Creating $link" -f Green
      make-link -target $target -link $link
      return 1
   } else {
      Write-Host "$link already exists" -f Green
      return 1
   }

   return 0
}

#
#   In this case, "_force" does not mean
#   any of the typical force ideas like force
#   the recursive overwrite of stuff.  It mean
#   do this because it is for te FORCE application.
#
function checkandcopycomponents_force {
   param ($target, $link)

   $isit = LinkOrDirectoryIsGood -DirName $link

   if ($isit -eq 0) {
      Write-Host "Copying $link" -f Green
      make-copy -target $target -link $link
      return 1
   } else {
      $answer = Read-Host -Prompt "$link already exists, overwrite\? (y or n)"
      $anser = $answer.ToLower()
      #
      #   If the answer is NOT y and it is not yes, consider
      #   it to be a negative response and redo.
      #
      if ($answer -eq "y") {
         Write-Host "$link already exists, overwriting" -f Green
         $link = Split-Path $link -Parent
         make-copy -target $target -link $link
      }
      return 1
   }

   return 0
}

#
#   Does the directory suit our needs?
#
function InputDirectoryIsGood {
   param ($DirName)

   if (-not (Test-Path -Path $DirName)) {
      Write-Host "Directory $DirName not found" -f Red
      return ""
   }

   if (-not (Test-Path -Path $DirName -PathType Container)) {
      Write-Host "File $DirName is not a Directory/Folder name" -f Red
      return ""
   }

   $DirName = (Get-Item $DirName).FullName

   return $DirName
}

#
#   Does the file suit our needs.
#
function InputFileIsGood {
   param ($FileName)

   $go_on = checkfilesuffix -FileName $FileName -Suffix ".ps1"
   if ($go_on -eq 0) {
      Write-Host "File must be a powershell (.ps1) file with a .ps1 suffix" -f Red
      return ""
   } else {
      if (-not (Test-Path -Path $FileName)) {
         Write-Host "File $FileName not found" -f Red
         return ""
      }
   }

   $FileName = (Get-Item $FileName).FullName

   return $FileName
}


#
# Check if the directory exists, and create it if it doesn't 
#
function buildthepath {
   param ($directoryPath)

   #
   # Check if the directory exists, and create it if it doesn't 
   #
   if (-not (Test-Path -Path $directoryPath)) {
      New-Item -ItemType Directory -Path $directoryPath
      if (-not (Test-Path -Path $directoryPath)) {
         Write-Host "Directory creation failed at $directoryPath" -f Red
         return 0
      }
      Write-Host "Directory created at $directoryPath" -f Green
   } else {
      Write-Host "Directory already exists at $directoryPath" -f Green
   }
   return 1
}

#
#   Is this script running as Administrator.
#
function amiadministrator {

   #
   #  "S-1-5-32-544" is the SID indicating that the app is running
   #  with "Run as administrator" selected as the run permissions.
   #
   $xxx = [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match "S-1-5-32-544"

   if ($xxx -contains "S-1-5-32-544") {
      Write-Host "Application is running as Administrator" -f Green
      return 1
   } else {
      Write-Host "Application is Not running as Administrator" -f Red
   }

   return 0
}

#
#   Take advantage of the fact that we had the common sense to
#   create all of the env files with the same file name format.
#   Create the expected file name on the fly.  If it is there,
#   return it.  Or the explicit string "NotFound" if the file
#   does not exist.
#
function returnAppEnvFile {
   param ($application, $ourroot)

   if ($application -eq "ALL") {
      return "ALL"
   }

   $appenvfile = $ourroot + "\app_env_files\"
   $application = $application.ToLower()
   $appenvfile = $appenvfile + $application + "_env.ps1"

   if (Test-Path $appenvfile) {
      return $appenvfile
   } 

   return "NotFound"
}

function newPublishProfile {
   param ($nameIt, $newPubLoc, $pubFileName)

   Write-Host "Would write to this location: " $nameIt

   $publoc = '       <PublishUrl>' + $newPubLoc + '</PublishUrl>'

   $origpath = 'bin\app.publish'
   $header = '<?xml version="1.0" encoding="utf-8"?>
   <Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
     <PropertyGroup>
       <DeleteExistingFiles>True</DeleteExistingFiles>
       <ExcludeApp_Data>False</ExcludeApp_Data>
       <LaunchSiteAfterPublish>True</LaunchSiteAfterPublish>
       <LastUsedBuildConfiguration>Release</LastUsedBuildConfiguration>
       <PublishProvider>FileSystem</PublishProvider>
       <LastUsedPlatform>Any CPU</LastUsedPlatform>'
   $trailer = '       <WebPublishMethod>FileSystem</WebPublishMethod>
       <SiteUrlToLaunchAfterPublish />
     </PropertyGroup>
   </Project>'

   Write-Output $header > $pubFileName
   Write-Output $publoc >> $pubFileName
   Write-Output $trailer >> $pubFileName

}

function buildProfilePath {
   param ($oldProjPath, $newName)

   $newProfilePath = ""
   $xx = ls $oldProjPath PublishProfiles -Recurse -Name

   foreach ($item in $xx) {
      $newProfilePath = $oldProjPath + "\" + $item + "\" + $newName
   }

   return $newProfilePath
}

#
#  Get the applicaton pool the user wants to use to run things.
#
function get_publish_location {
   param ($PublishPath)

   $PublishName = Read-Host -Prompt "Input the application Publish Location.  Default is $PublishPath"

   if ([string]::IsNullOrWhiteSpace($PublishName)) {
      $PublishName = $PublishPath
      Write-Host "Using Default:  $PublishPath" -f Yellow
   } else {
      Write-Host "Using provided publication path:  $PublishName" -f Yellow
      if (-Not (Test-Path -Path $PublishName)) {
         Write-Host "Publication directory does not exist. It will be created at publish time ..." -f Yellow
      }
   }

   return $PublishName
}

#
#   Get rid of the oldest back up directories.
#   Currently leaves 3 the fit our naming convention.
#
function clearBackups {
   param ($PoolPath, $RemoteServer)

   $baseName = Split-Path $PoolPath -leaf
   $rootName = Split-Path $PoolPath -Parent
   $pathForm = $baseName + "_Backup*"

   $xx = Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
         param ($rootName, $pathForm)
         Get-ChildItem -Path "$rootName" -Directory "$pathForm" | sort CreationTime
   } -ArgumentList $rootName, $pathForm
   $mine = $xx.count
   if ($mine -gt 1) {
      $mine = $mine - 1
      $t = 0
      echo $xx | ForEach {
         if ($t -lt $mine) {
            $fullPath = $rootName + "\" + $_
            Write-Host "Delete backup path:  $fullPath" -f Red
            Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
               param ($fullPath)
               Remove-Item -Path "$fullPath" -Force -Recurse
            } -ArgumentList $fullPath
            $t = $t + 1
         }
      }
   }
   return
}

function getConfigFileLoc {
   param ($myServer)

   if ($myServer -eq "BetaInternal") {
      return "DevBeta"
   } elseif ($myServer -eq "BetaExternal") {
      return "DevBeta"
   } elseif ($myServer -eq "Charlie") {
      return "DevCharlie"
   } else {
      return "DevAlpha"
   }
}


function izitzipit {
   param ($myServer, $zipfile)

   if ($myServer -eq "Test") {
      $zipfile = 1
   } elseif ($myServer -eq "PreProd") {
      $zipfile = 1
   } else {
      $zipfile = 0
   }

   return $zipfile
}

#
#   Create a zip file rather than do a deployment
#
function zip_not_deploy {
   param ($PublishPath, $application)

   $destFile = $ScriptPath + "\" + $application + ".zip"

   Write-Host "Doing a zip, not a deploy: $destFile" -f Red
   Compress-Archive -LiteralPath $PublishPath -DestinationPath $destFile

   return
}


#
#  Installs ALL of the applications within a supplied directory
#  This works by looking for individual files in the supplied
#  directory.  So, while it say "ALL", it is a bit of a misnomer.
#  ALL really means "the config files that are present".  The
#  default directory is "ALL", but any directory can be supplied
#  as long as that is where the deploy/config files are located.
#
function runAll {
   param ([string]$AllDirectory = "ALL",
          $zipfile)

   $RunStartPoint = (Get-Location).Path

   $thing = Get-ChildItem -Literal "$AllDirectory"
   $thing | ForEach {
      $CurrentFile = "$AllDirectory\$_"
      Write-Host "Checking $CurrentFile" -f Yellow
      $UseFile = InputFileIsGood -FileName $CurrentFile
      if ($UseFile -ne "") {
         Write-Host "Running $UseFile" -f Green
         . $UseFile
         dump_file_data
         mainLine -zipfile $zipfile -doVerify 0
      } else {
         Write-Host "Skipping $CurrentFile.  Not a powershell (.ps1) file" -f Red
      }
      #
      #   Return to the starting point
      #   so we can always find things correctly
      #
      Set-Location -Path $RunStartPoint
   }
   return
}

#
#  Just print the current variable settings that are used
#  by other functions.
#
function dump_file_data {

   $myoutput = '$application = ' + $application
   Write-Host $myoutput
   $myoutput = '$cfgbranch = ' + $cfgbranch
   Write-Host $myoutput
   $myoutput = '$appbranch = ' + $appbranch
   Write-Host $myoutput
   $myoutput = '$ConfigPath = ' + $ConfigPath
   Write-Host $myoutput
   $myoutput = '$PublishPath = ' + $PublishPath
   Write-Host $myoutput
   $myoutput = '$ProjectPath = ' + $ProjectPath
   Write-Host $myoutput
   $myoutput = '$RemoteServer = ' + $RemoteServer
   Write-Host $myoutput
   $myoutput = '$RemotePath = ' + $RemotePath
   Write-Host $myoutput
   $myoutput = '$ConfigAppPath = ' + $ConfigAppPath
   Write-Host $myoutput
   $myoutput = '$AppPoolName = ' + $AppPoolName
   Write-Host $myoutput

}

#
#  Save the current variable settings that are used
#  by other functions so they can be used in subsequent
#  runs; saving the user from answering all the questions
#  again.
#
#  There is a variable called $whichcfg which is not
#  included here because it is incorporated into the
#  $ConfigAppPath variable.
#
function save_file {
   param ($SaveFileName, $FilePath)

   $myfile = $FilePath + "\" + $SaveFileName

   Write-Host "Writing to: $myfile"

   $myoutput = '$application = "' + $application + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$cfgbranch = "' + $cfgbranch + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$appbranch = "' + $appbranch + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$ConfigPath = "' + $ConfigPath + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$usedotnet = ' + $usedotnet
   Write-Output $myoutput >> $myfile

   $myoutput = '$PathBase = "' + $PathBase + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$PublishPath = "' + $PublishPath + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$ProjectPath = "' + $ProjectPath + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$RemoteServer = "' + $RemoteServer + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$RemotePath = "' + $RemotePath + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$ConfigAppPath = "' + $ConfigAppPath + '"'
   Write-Output $myoutput >> $myfile

   $myoutput = '$AppPoolName = "' + $AppPoolName + '"'
   Write-Output $myoutput >> $myfile

}

function continueortryagain {
   param ($myPath)

   Write-Host "Specified path, $myPath, does not exist" -f Red
   Write-Host 'Answering "n" will re-prompt for correct directory' -f Yellow
   Write-Host 'Answering "y" will cause directory creation and project clone' -f Yellow
   $answer = Read-Host -Prompt "Continue (y or n)?"
   $answer = $answer.ToLower()

   return $answer
}

function SelectAnswerYesNo {
   param ($myPath, $yesMessage, $noMessage)

    $yessir = "Yes | " + $yesMessage
    $nosir = "No | " + $noMessage
    # $anslist = @("Yes | Directory will be created and the project cloned into it", "No | I messed up, reinput directory name")
    $anslist = @($yessir, $nosir)
    #$answer = ForEach-Object { $anslist } | Sort-Object | Out-GridView -Title "$myPath does not exist.  Shall we continue?" -OutputMode Single
    $answer = ForEach-Object { $anslist } | Sort-Object | Out-GridView -Title $myPath -OutputMode Single

   $answer = $answer.Split(" ")[0]

   #$Correct_Item = Read-Host -Prompt "$answer selected. Correct (y or n)\?"

   #if ($Correct_Item -eq "No") {
   #   $answer = SelectAnswerYesNo
   #}

   return $answer
}

function get_app_project_directory {
   param ($default_path)

   $whichpath = "repository"

   $PathBase = Read-Host -Prompt "Input the path to the $whichpath.  Default is $default_path"

   if ([string]::IsNullOrWhiteSpace($PathBase)) {
      $PathBase = $default_path
      Write-Host "Using Default:  $PathBase" -f Green
   } else {
      if (!(Test-Path -Path $PathBase)) {
         $yesMessage = "Directory will be created and the project cloned into it"
         $noMessage = "I messed up, reinput directory name"
         $displayQuestion = $PathBase + " does not exist, Shall We Continue?"
         $answer = SelectAnswerYesNo -myPath $displayQuestion -yesMessage $yesMessage -noMessage $noMessage
         if ($answer -eq "No") {
            $PathBase = get_app_project_directory -default_path "$default_path"
         }
      } else {
         Write-Host "Using provided path:  $PathBase" -f Green
      }
      # throw "Specified path does not exist"
   }

   return $PathBase
}

#
#  Get the directory where the repo is.
#  or where the deployment is to be
#  or the "All" directory
#
function get_project_directory {
   param ($default_path, $RemoteServer, $which)

   $existStatus = "False"

   $whichpath = "repository"
   if ($which -eq 1) {
      if ($RemoteServer -eq "BuildOnly") {
         return ""
      }
      $whichpath = "deployment path"
   } elseif ($which -eq 2) {
      $whichpath = "deployment files"
   } else {
      $whichpath = "repository"
   }

   $PathBase = Read-Host -Prompt "Input the path to the $whichpath.  Default is $default_path"

   if ([string]::IsNullOrWhiteSpace($PathBase)) {
      $PathBase = $default_path
      Write-Host "Using Default:  $PathBase" -f Green
   } else {
       try {
         $existStatus = Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
             param ($PathBase)
             Import-Module WebAdministration
             Test-Path -Path $PathBase 2>&1
         } -ArgumentList $PathBase
      } catch {
         Write-Output "Path Existence Check Error:  $_"
         throw
      }

      if (-not $existStatus) {
         Write-Host "Folder does not exist. ReEnter path ..." -f Red
         $PathBase = get_project_directory -default_path "$default_path" -RemoteServer $RemoteServer -which $which
         # throw "Specified path does not exist"
      } else {
         Write-Host "Using provided path:  $PathBase" -f Green
      }
   }

   return $PathBase
}

#
#  Copy the published application to the pool directory
#
function copy_app {
   param ($PublishPath, $RemotePath, $CfgBranch)

   # Copy files to the remote server, ensuring all files are overwritten
   Write-Host "`n`n==================================================================================================="
   Write-Host "Copying files to the remote server..."
   Write-Host "==================================================================================================="
   # Ensure all files are overwritten and delete files that no longer exist
   try {
      if ($CfgBranch -ne "ASIS_LOCAL") {
         Robocopy $PublishPath $RemotePath /MIR /R:5 /W:2 /NP /XD logs /XF appsettings.json web.config log4net.config | Write-Host -f DarkCyan
      } else {
         Robocopy $PublishPath $RemotePath /MIR /R:5 /W:2 /NP /XD logs | Write-Host -f DarkCyan
      }
   } catch {
      Write-Output "Build Copy Error:  $_"
      throw
   }

   Write-Host $rout

   return
}

#
#  Copy the application config files from the config repo/directory.
#
function copy_configs {
   param ($ConfigAppPath, $RemotePath)

   # Copy files to the remote server, ensuring all files are overwritten
   Write-Host "`n`n==================================================================================================="
   Write-Host "Copying configs to the remote server..."
   Write-Host "==================================================================================================="
   # Ensure all files are overwritten and delete files that no longer exist
   try {
      Robocopy $ConfigAppPath $RemotePath /R:5 /W:2 /NP /XD logs /XF _placeholder.txt | Write-Host -f DarkCyan
   } catch {
      Write-Output "Configuration File Copy Error:  $_"
      throw
   }
}

#
# Backup the existing remote folder
#
function backup_current_app {
   param ($RemotePath)

   $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
   $BackupPath = "$RemotePath`_Backup_$Timestamp"

   Write-Host "`n`n==================================================================================================="
   Write-Host "Backing up current deployment to: $BackupPath..."
   Write-Host "==================================================================================================="

   #
   #   Clear excess number of backups
   #   Limit the number to 3 of that directory
   #   Warning:  This deletes the excess directories
   #   regardless of the application contained within the
   #   backup.  So if you have been putting ASB into a path,
   #   but one of the old ones to that path contains Force,
   #   it will still be deleted.
   #
   try {
      clearBackups -PoolPath "$RemotePath" -RemoteServer $RemoteServer
   } catch {
      throw "Clearing backups: $RemotePath"
   }

   try {
      Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
          param ($Source, $Backup)
          if (Test-Path $Source) {
              Copy-Item -Path $Source -Destination $Backup -Recurse -Force
              Write-Host "Backup completed successfully!" -f Green
          } else {
              Write-Host "Warning: Source path does not exist, skipping backup." -f Red
          }
      } -ArgumentList $RemotePath, $BackupPath
   } catch {
      Write-Output "Backup Error:  $_"
      throw
   }

   return 0
}

#
#  Build/publish the selected application
#
function publish_the_application {
   param ($PublishPath, $ProjectPath, $UseDotNet)

   Write-Host "`n`n==================================================================================================="
   Write-Host "Publishing the .NET project..."
   Write-Host "==================================================================================================="

   if (!(Test-Path -Path $PublishPath)) {
       Write-Host "Folder does not exist. Creating it now..." -f Yellow
       try {
          New-Item -ItemType Directory -Path $PublishPath | Out-Null
       } catch {
          Write-Output "Publish Path creation error:  $_"
          throw
       }
       Write-Host "Folder created: $PublishPath" -f Green
   } else {
       Write-Host "Folder already exists: $PublishPath" -f Yellow
   }

   if ($ProjectFile -ne $null -and $ProjectFile -ne "") {
      $ProjectPath = $ProjectPath + $ProjectFile
   }

   try {
      if ($UseDotNet -eq 1) {
         #
         # dotnet msbuild $ProjectPath /p:Configuration=Release
         # /p:DesignTimeBuild=true /t:ResolveProjectReferences
         #
         Write-Host "dotnet build $ProjectPath -c Release" -f Green
         dotnet build $ProjectPath -c Release | Write-Host -f Cyan
         $b1result = $?
         Write-Host "dotnet publish $ProjectPath -c Release -o $PublishPath" -f Green
         dotnet publish $ProjectPath -c Release -o $PublishPath | Write-Host -f Cyan
         $b2result = $?
      } else {
         #   msbuild does not do everything with one command
         #   So the first does the package restore
         #   The second does the design time stuff
         #   The third does the build and publish
         #
         Write-Host "msbuild /t:restore /p:RestorePackagesConfig=true" -f Green
         msbuild /t:restore /p:RestorePackagesConfig=true | Write-Host -f Cyan
 
         Write-Host "msbuild $ProjectPath /p:Configuration=Release /p:DesignTimeBuild=true /t:ResolveProjectReferences" -f Green
         msbuild $ProjectPath /p:Configuration=Release /p:DesignTimeBuild=true /t:ResolveProjectReferences | Write-Host -f Cyan
         $b1result = $?
 
         Write-Host "msbuild $ProjectPath /p:Configuration=Release /p:DeployOnBuild=true /p:PublishProfile=$PublishProfile" -f Green
         msbuild $ProjectPath /p:Configuration=Release /p:DeployOnBuild=true /p:PublishProfile=$PublishProfile | Write-Host -f Cyan
         $b2result = $?
      }
      if (-not $b2result) {
         Write-Host "Build errors:  The project apparently failed to build" -f Red
         $answer = Read-Host -Prompt "Continue anyway(y or n)\?"
         if ($answer -eq "n") {
            throw "Build Errors:  The project failed to build"
         }
      }

   } catch {
      Write-Host "Publish/Build Error:  $_" -f Red
      throw
   }

   return
}
