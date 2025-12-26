#!pwsh
#

param ($isEntra = "yes",
       $runas = "",
       $port = "",
       $which = "alpha")

$tcount=0
$tpass=0
$tfail=0

$faillist = New-Object System.Collections.ArrayList

$cmdargs = "-isEntra $isEntra -which $which"
if ($port -ne "") {
   $cmdargs = "$cmdargs -port $port"
}
if ($runas -ne "") {
   $cmdargs = "$cmdargs -runas $runas"
}

$items = Get-Content -Path "test.lst"
$items | ForEach {
   Write-Host "Running:  $_ $cmdargs" -f Blue
   $tcount= $tcount + 1
   pwsh -Command ./$_ $cmdargs
   $zz = $?
   if ( $zz -ne 0 ) {
      Write-Host $_":  Test Passed" -f Green
      $tpass = $tpass + 1
   } else {
      Write-Host $_":  Test Failed" -f Red
      $tfail = $tfail + 1
      [void]$faillist.Add($_)
   }
   echo "Completed:  $_"
   echo "#################################################"
   echo ""
}

Write-Host "Tests Run:    $tcount" -f Yellow
Write-Host "Tests Passed: $tpass" -f DarkGreen
Write-Host "Tests Failed: $tfail" -f DarkRed
if ($tfail -gt 0) {
   Write-Host "Failed Tests:" -f DarkRed
   $faillist | ForEach {
      Write-Host "   $_" -f DarkRed
   }
}
