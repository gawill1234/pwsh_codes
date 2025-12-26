@echo off

set base=d:\Application_Development\Shared\AutoDeploy\App\-eCOR
IF NOT "%~1"=="" set base=%1

echo base = %base%

set mylink=%base%\src\cor-home
set target=d:\Application_Development\Shared\AutoDeploy\AppComponents\-eCOR\src\cor-home

echo mylink = %mylink%
echo target = %target%

mklink /D %mylink%\bower_components %target%\bower_components

mklink /D %mylink%\node_modules %target%\node_modules
