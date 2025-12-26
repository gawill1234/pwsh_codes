@echo off

set base=d:\Application_Development\Shared\AutoDeploy\App\-eCOR
IF NOT "%~1"=="" set base=%1

echo base = %base%

set mylink=%base%\src\cor-home
set target=d:\Application_Development\Shared\AutoDeploy\AppComponents\-eCOR\src\cor-home

echo mylink = %mylink%
echo target = %target%

xcopy /S /I /E /Q %target%\bower_components %mylink%\bower_components

xcopy /S /I /E /Q %target%\node_modules %mylink%\node_modules
