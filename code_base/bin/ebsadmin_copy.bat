@echo off

set base=d:\Application_Development\Shared\AutoDeploy\App\-EBSAdmin
IF NOT "%~1"=="" set base=%1

echo base = %base%

set mylink=%base%\ClientApp
set target=d:\Application_Development\Shared\AutoDeploy\AppComponents\-EBSAdmin\ClientApp

echo mylink = %mylink%
echo target = %target%

xcopy /S /I /E /Q %target%\node_modules %mylink%\node_modules
