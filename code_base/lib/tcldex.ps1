#! pwsh
#
#   Just a simple example of trying to load
#   a power shell file using a try/catch
#   so if it fails, you can write an error.
#   As a side effect, an example of using
#   a random string and fake email address
#   generator.
#

try {
   . ../lib/myFunctions.ps1
} catch {
   Write-Host "Could not find myFunctions.ps1" -f magenta
   exit 1
}

Write-Host "#########" -f DarkRed
Write-Host "Random string, default setup, length is 10" -f DarkYellow
$value = ranstringuln
Write-Host $value -f Yellow

Write-Host "#########" -f DarkRed
Write-Host "Random string, string length set to 30" -f DarkYellow
$value = ranstringuln -stlen 30
Write-Host $value -f Yellow

Write-Host "#########" -f DarkRed
Write-Host "Fake email, default setup, domain is va.gov" -f DarkYellow
$maddr = fakeEmail
Write-Host $maddr -f Yellow

Write-Host "#########" -f DarkRed
Write-Host "Fake email, domain set to gmail.com" -f DarkYellow
$maddr = fakeEmail -maildomain "gmail.com"
Write-Host $maddr -f Yellow
