@echo off

set base=d:\Application_Development\Shared\AutoDeploy\App\-FORCE
IF NOT "%~1"=="" set base=%1

echo base = %base%

set mylink=%base%\Force\ClientApp
set target=d:\Application_Development\Shared\AutoDeploy\AppComponents\-FORCE\Force\ClientApp

echo mylink = %mylink%
echo target = %target%

xcopy /S /I /E /Q %target%\node_modules %mylink%\node_modules
