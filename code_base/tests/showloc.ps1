#! pwsh
#
#   One of the more "complex" tests has 42 lines of code.
#   This is the only comment so it can be seen more readily.
#
param ($which = "alpha",
       $dump = "")

. ../lib/appstatus.ps1
$runas = "force"
$myuri = full_base_uri -server $which -app "asb"
if ($which -eq "alpha") {
   $fulluri = Add_route -uri $myuri -route "Requirements" -query "1352071"
   $answer = 1352071
} elseif ($which -eq "beta") {
   $fulluri = Add_route -uri $myuri -route "Requirements" -query "1"
   $answer = 1
} else {
   Write-Host "Need a number to look for in charlie.  Not set yet." -f Red
   Write-Host "Possibly no FORCE items in charlie db." -f Red
   $fulluri = Add_route -uri $myuri -route "Requirements" -query "0"
   $answer = $null
}
$headers = auth_header -runas "force"
$Response = run_uri_b -uri $fulluri -headers $headers
if ($dump -eq "yes") {
   Write-Host $Response
}
Write-Host "URI:  $fulluri" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($which -eq "charlie") {
      Write-Host "ASB - /Requirements on" $which":  Test Passed " -f Green
      Write-Host "  On charlie, we have no FORCE requirements data." -f Green
      Write-Host "  So an empty success is ok for passing; for now." -f Green
      exit 0
   } else {
      if ($mine.result.RequirementId -eq $answer) {
         Write-Host "ASB - /Requirements on" $which":  Test Passed " -f Green
         exit 0
      }
   }
}
Write-Host $Response
Write-Host "ASB - /Requirements on" $which":  Test Failed " -f Red
exit 1
