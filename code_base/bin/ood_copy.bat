@echo off

set base=d:\Application_Development\Shared\AutoDeploy\App\-OOD
IF NOT "%~1"=="" set base=%1

echo base = %base%

set mylink=%base%\src\UI\ecert-home
set target=d:\Application_Development\Shared\AutoDeploy\AppComponents\-OOD\src\UI\ecert-home

echo mylink = %mylink%
echo target = %target%

xcopy /S /I /E /Q %target%\bower_components %mylink%\bower_components

xcopy /S /I /E /Q %target%\node_modules %mylink%\node_modules
