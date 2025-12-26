@echo off

set base=d:\Application_Development\Shared\AutoDeploy\App\-EASAdmin
IF NOT "%~1"=="" set base=%1

echo base = %base%

set mylink=%base%\src\EASAdmin\ClientApp
set target=d:\Application_Development\Shared\AutoDeploy\AppComponents\-EASAdmin\src\EASAdmin\ClientApp

echo mylink = %mylink%
echo target = %target%

mklink /D %mylink%\node_modules %target%\node_modules
