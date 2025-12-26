#! pwsh
#
function amiadministrator {
   $xxx = [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match "S-1-5-32-544"

   if ($xxx -contains "S-1-5-32-544") {
      return 1
   }

   return 0
}

$admincheck = amiadministrator

if ($admincheck -eq 0) {
   Write-Host "No you are not Administrator" -f DarkRed
   exit 0
}
Write-Host "Yes you are Administrator" -f Green
exit 1
