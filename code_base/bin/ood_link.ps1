#! pwsh
#
param ([string]$MyRepo = "",
       [string]$ComponentRepo = "",
       [string]$Base = "")


#
#  Create a symlink
#
function make-link {
   param ($target, $link)

   $farkle = New-Item -Path $link -ItemType SymbolicLink -Value $target 2>&1

   return $?
}

if ($Base -eq "") {
   $Base = "d:\Application_Development\Shared\AutoDeploy"
}
if ($MyRepo -eq "") {
   $MyRepo = $Base + "\Apps\-OOD"
}
if ($ComponentRepo -eq "") {
   $ComponentRepo = $Base
}

$myLink = $MyRepo + "\src\UI\ecert-home"

$myTarget = $ComponentRepo + "\AppComponents\-OOD\src\UI\ecert-home"

Write-Host "Linking node_modules from $myTarget to $myLink" -f Green
Write-Host "Linking node_modules from $myTarget to $myLink" -f Green
Start-Sleep -seconds 2

$goob = make-link -target $myTarget\bower_components -link $myLink\bower_components
if (-not $goob) {
   Write-Host "$myLink\bower_components already exists" -f Red
} else {
   Write-Host "$myLink\bower_components created" -f Green
}

$goob = make-link -target $myTarget\node_modules -link $myLink\node_modules
if (-not $goob) {
   Write-Host "$myLink\node_modules already exists" -f Red
} else {
   Write-Host "$myLink\node_modules created" -f Green
}
