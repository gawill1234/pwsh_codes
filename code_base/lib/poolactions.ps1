#
#  This file contains the functions associated with manipulating
#  the application pool in IIS.  Though one, get_application_pool,
#  is just to get the name of a pool if it differs from the default
#  given for any application.
#
#  The functions have been created to be an entire step in 
#  the deploy process.  So we have:
#     pool_status -- current status of selected pool
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
#  Get the applicaton pool the user wants to use to run things.
#
function get_application_pool {
   param ($default_pool, $RemoteServer)

   if ($default_pool -eq "NoPool") {
      return "NoPool"
   }

   if ($RemoteServer -eq "BuildOnly") {
      return ""
   }

   $PoolName = Read-Host -Prompt "Input the Application Pool name.  Default is $default_pool"

   if ([string]::IsNullOrWhiteSpace($PoolName)) {
      $PoolName = $default_pool
      Write-Host "Using Default:  $PoolName" -f Green
   } else {
      # $MyAppPoolData = Get-IISAppPool $PoolName
      try {
         $MyAppPoolData = Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
             param ($PoolName)
             Import-Module WebAdministration
             Get-IISAppPool $PoolName 2>&1
         } -ArgumentList $PoolName
      } catch {
         Write-Output "Pool Existence Check Error:  $_"
         throw
      }
      if ([string]::IsNullOrWhiteSpace($MyAppPoolData)) {
         Write-Host "Application pool does not exist. ReEnter ..." -f Yellow
         $PoolName = get_application_pool -default_pool "$default_pool"
         # throw "Application Pool is null or does not exist"
      } else {
         Write-Host "Using provided pool:  $PoolName" -f Green
      }
   }

   return $PoolName
}


#
#   Get the current App pool status
#   Mostly looking for "Started" or "Stopped"
#
function pool_status {
   param ($AppPoolName, $RemoteServer)

   $out = Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
       param ($AppPool)
       Import-Module WebAdministration
       (Get-WebAppPoolState $AppPool).Value
   } -ArgumentList $AppPoolName
   $out = [string]::join("",($out.Split("`n")))
   Write-Host "(POOL STATUS) Current status: " $out

   return $out
}

#
#  Stop the IIS application pool selected for the app use
#
function stop_pool {
   param ($AppPoolName, $RemoteServer)

   #
   #   "NoPool" means the affected app has no pool associated
   #   with it.  So just return.
   #
   if ($AppPoolName -eq "NoPool") {
      return
   }

   Write-Host "`n`n==================================================================================================="
   Write-Host "Stopping App Pool: $AppPoolName on $RemoteServer..."
   Write-Host "==================================================================================================="
   $out = pool_status -AppPoolName $AppPoolName -RemoteServer $RemoteServer
   if ($out -ne "Stopped") {
      try {
         $out = Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
             param ($AppPool)
             Import-Module WebAdministration
             Stop-WebAppPool -Name $AppPool 2>&1
         } -ArgumentList $AppPoolName
      } catch {
         Write-Output "Stop Pool Error:  $_"
         throw
      }
      $count = 0
      do {
         $count = $count + 1
         Start-Sleep -Seconds 1
         $out = pool_status -AppPoolName $AppPoolName -RemoteServer $RemoteServer
         #
         #   Loop limit value.  We have not yet had issues with
         #   setting/getting pool status.  When we see the failure
         #   mode, retry will be set accordingly.
         #   So, waiting on better experience.
         #
         if ($count -ge 3) {
            return
         }
      } until ( $out -eq "Stopped" )
   }

   return
}

#
#  Start the IIS application pool selected for the app use
#
function start_pool {
   param ($AppPoolName, $RemoteServer)

   #
   #   "NoPool" means the affected app has no pool associated
   #   with it.  So just return.
   #
   if ($AppPoolName -eq "NoPool") {
      return
   }

   Write-Host "`n`n==================================================================================================="
   Write-Host "Starting App Pool: $AppPoolName on $RemoteServer..."
   Write-Host "==================================================================================================="
   $out = pool_status -AppPoolName $AppPoolName -RemoteServer $RemoteServer
   if ($out -ne "Started") {
      try {
         $out = Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
             param ($AppPool)
             Import-Module WebAdministration
             Start-WebAppPool -Name $AppPool 2>&1
         } -ArgumentList $AppPoolName
      } catch {
         Write-Output "Start Pool Error:  $_"
         throw
      }
   }
   $count = 0
   do {
      $count = $count + 1
      Start-Sleep -Seconds 1
      $out = pool_status -AppPoolName $AppPoolName -RemoteServer $RemoteServer
      #
      #   Loop limit value.  We have not yet had issues with
      #   setting/getting pool status.  When we see the failure
      #   mode, retry will be set accordingly.
      #
      if ($count -ge 3) {
         return
      }
   } until ( $out -eq "Started" )

   return
}
