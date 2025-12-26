#
#   Get an appropriate application list based on the environment.
#   For the moment this looks at the longer list that it cares
#   about.  If the item in question is in one list, it returns
#   the appropriate list.  Otherwise, it returns the other.
#
function get_app_list {
   param ($myEnv)

   $external_list = @("VOAExternal", "eVP", "CCST", "EpicExternalWebService")
   $internal_list = @("OOD", "eCOR", "EBSTimerJobs", "EASAdmin", "EBSAdmin", "EBSProfile", "EPIC", "EpicWebService", "VendorWebService", "FORCE", "ASB", "JobScheduler", "VOAInternal")
   $full_list = @("OOD", "eCOR", "EBSTimerJobs", "EASAdmin", "EBSAdmin", "EBSProfile", "EPIC", "EpicWebService", "VendorWebService", "FORCE", "ASB", "JobScheduler", "VOAInternal", "VOAExternal", "eVP", "CCST", "EpicExternalWebService")

   $internal_env = @("BetaInternal", "Alpha", "Charlie")

   if ($myEnv -eq "BuildOnly") {
      return $full_list
   }
   
   # Write-HOst "Selected:  $myEnv" -f Magenta
   $foundapp = $internal_env | Where-Object {$_ -eq $myEnv}
   # Write-HOst "Found:  $foundapp" -f Magenta

   if ($foundapp -eq $null -or $foundapp -eq "") {
      return $external_list
   }

   return $internal_list
}

#
#   Get an appropriate environment list based on the application.
#   For the moment this looks at the longer list that it cares
#   about.  If the item in question is in one list, it returns
#   the appropriate list.  Otherwise, it returns the other.
#
function get_env_list {
   param ($myApp)

   $internal_list = @("OOD", "eCOR", "EBSTimerJobs", "EASAdmin", "EBSAdmin", "EBSProfile", "EPIC", "EpicWebService", "VendorWebService", "FORCE", "ASB", "JobScheduler", "VOAInternal")

   $internal_env = @("BetaIxternal", "Alpha", "Charlie")
   $external_env = @("BetaExternal")
   
   # Write-HOst "Selected:  $myApp" -f Magenta
   $foundapp = $internal_list | Where-Object {$_ -eq $myApp}
   # Write-HOst "Found:  $foundapp" -f Magenta

   if ($foundapp -eq $null -or $foundapp -eq "") {
      return $external_env
   }

   return $internal_env
}

#
#   Yes, we could have one function do this compare and pass
#   in a flag to set the lists or pass in the lists (along with
#   the items we are checking).  But, this way limited the conditions
#   in each function and made it clear whether it was an
#   internal or external application/env that was being checked.
#
#   This is a true or false thing.  The item is there or it is not.
#
function internal_match {
   param ($myServer, $myApp)

   $internal_env = @("BetaIxternal", "Alpha", "Charlie")
   $internal_list = @("OOD", "eCOR", "EBSTimerJobs", "EASAdmin", "EBSAdmin", "EBSProfile", "EPIC", "EpicWebService", "VendorWebService", "FORCE", "ASB", "JobScheduler", "VOAInternal")

   $foundapp = $internal_list | Where-Object {$_ -eq $myApp}
   $foundenv = $internal_env | Where-Object {$_ -eq $myServer}

   if ($foundapp -eq $null -or $foundapp -eq "") {
      return 0
   }
   if ($foundenv -eq $null -or $foundenv -eq "") {
      return 0
   }

   return 1
}

#
#   This is a true or false thing.  The item is there or it is not.
#   Is the application supposed to run internally or externally.
#   If external, return 1.  Otherwise, 0.
#
function external_match {
   param ($myServer, $myApp)

   $external_list = @("VOAExternal", "eVP", "CCST", "EpicExternalWebService")
   $external_env = @("BetaExternal")

   $foundapp = $external_list | Where-Object {$_ -eq $myApp}
   $foundenv = $external_env | Where-Object {$_ -eq $myServer}

   if ($foundapp -eq $null -or $foundapp -eq "") {
      return 0
   }
   if ($foundenv -eq $null -or $foundenv -eq "") {
      return 0
   }

   return 1
}

#
#   Does the selected application pair with the
#   selected environment?  I.e., is it an
#   internal app with an internal server or are
#   they both external.
#
function app_env_togetherness {
   param ($myServer, $myApp)

   $doesit = internal_match -myServer $myServer -myApp $myApp
   if ($doesit -eq 1) {
      return 1
   }

   $doesit = external_match -myServer $myServer -myApp $myApp
   if ($doesit -eq 1) {
      return 1
   }

   return 0
}

#
#   Mostly this returns the url address of each remote
#   server.  The exceptions are for Test and PreProd.  For
#   those it just returns the equivalent strings.  That is
#   then used to set things to create a zip file rather than
#   attempt to deploy the build.
#
function getRemoteAddress {
   param ($myServer)

   #
   #   Alpha will be the default.
   #   Done with the seemingly useless initialization of
   #   values here at the beginning to make updating those
   #   values easier if they should change.  They are all
   #   in one place with no hidden logic to worry about.
   #
   #   Old Alpha
   # $Alpha = "vac20appaes800.va.gov"  # Change to your VM name
   #
   #   New Alpha
   $Alpha = "vac20appaes801.va.gov"  # Change to your VM name
   #
   #   Old Beta
   # $BetaInternal = "vac20webaes840.va.gov"
   #
   #   Test by ip address
   $Test = 10.245.109.8
   #
   #   New Beta
   $BetaInternal = "vac20webaes842.va.gov"
   $BetaExternal = "vac20webaes871.va.gov"
   $Charlie = "vac20webaes841.va.gov"
   # $Test = "Test"
   # $PreProd = "PreProd"

   if ($myServer -eq "BetaInternal") {
      $RemAddress = $BetaInternal
   } elseif ($myServer -eq "BetaExternal") {
      $RemAddress = $BetaExternal
   } elseif ($myServer -eq "Charlie") {
      $RemAddress = $Charlie
   } elseif ($myServer -eq "Test") {
      $RemAddress = $Test
   } else {
      $RemAddress = $Alpha
   }

   return $RemAddress
}

#
#   Select the server
#
function SelectRemoteServer {

   # $whichServer = @("Alpha", "BetaInternal", "BetaExternal", "Charlie", "Test", "Prod", "PreProd", "Train")
   $whichServer = @("Alpha", "BetaInternal", "BetaExternal", "Charlie")
   $myServer = ForEach-Object { $whichServer } | Sort-Object | Out-GridView -Title "Select a targer server" -OutputMode Single

   #$Correct_Item = Read-Host -Prompt "$myServer selected. Correct (y or n)\?"

   #if ($Correct_Item -eq "n") {
   #   $myServer = SelectRemoteServer
   #}

   return $myServer
}

#
#   Select the application
#
function SelectApplication {
    param ($myEnv)

    $applist = get_app_list -myEnv $myEnv

    ## $applist = @("OOD", "eCOR", "EBSTimerJobs", "EASAdmin", "EBSAdmin", "EBSProfile", "EPIC", "eVP", "EpicWebService", "VendorWebService", "FORCE", "ASB", "JobScheduler", "VOAInternal", "VOAExternal", "CCST")
    $application = ForEach-Object { $applist } | Sort-Object | Out-GridView -Title "Select an Application" -OutputMode Single

   #$Correct_Item = Read-Host -Prompt "$application selected. Correct (y or n)\?"

   #if ($Correct_Item -eq "n") {
   #   $application = SelectApplication
   #}

   return $application
}

#
#   Verify that the selections are correct.  Print
#   them so the user can verify the list is correct.
#
function VerifySelections {

   $redo = 0

   Write-Host "These are your selections: " -f DarkGreen

   Write-Host "   Application Root: $APPROOT" -f DarkGreen
   Write-Host "   Application:      $application" -f DarkGreen
   Write-Host "   Project Repo:     $PathBase" -f DarkGreen
   Write-Host "   Project Path:     $ProjectPath" -f DarkGreen
   Write-Host "   Project Branch:   $appbranch" -f DarkGreen
   Write-Host "   Config Path:      $ConfigPath" -f DarkGreen
   Write-Host "   Config App Path:  $ConfigAppPath" -f DarkGreen
   Write-Host "   Config Branch:    $cfgbranch" -f DarkGreen
   if ($AppPoolName -eq "NoPool") {
      Write-Host "   IIS AppPool:      Pool not applicable for this application" -f DarkGreen
   } else {
      Write-Host "   IIS AppPool:      $AppPoolName" -f DarkGreen
   }
   Write-Host "   Remote Server:    $RemoteServer" -f DarkGreen
   Write-Host "   Remote Location:  $RemotePath" -f DarkGreen
   Write-Host "   Publish to:       $PublishPath" -f DarkGreen

   #
   # $yesMessage = "We will continue using the listed selections"
   # $noMessage = "You will be asked to re-enter the selection data"
   # $displayQuestion = "Are the listed selections correct?"
   # $answer = SelectAnswerYesNo -myPath $displayQuestion -yesMessage $yesMessage -noMessage $noMessage
   #

   $answer = Read-Host -Prompt "Are the above selections correct (y or n)\?"
   $anser = $answer.ToLower()

   #
   #   If the answer is NOT y and it is not yes, consider
   #   it to be a negative response and redo.
   #
   if ($answer -ne "y" -and $answer -ne "yes") {
      $redo = 1
   }

   return $redo
}
