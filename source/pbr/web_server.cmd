:: PBR Web server command line utility.
::
:: Package: PBR extension for SketchUp
:: Copyright: © 2018 Samuel Tallet-Sabathé
:: License: GNU General Public License 3.0

@echo off

title PBR Web server

:: Go to NGINX directory.
cd /d "%~dp0%Web Server"

::
:: Parse argument passed to this script.
::
if %1 == start ( goto start )
if %1 == stop ( goto stop )
:: else
echo Invalid argument error.
exit 1

::
:: Start NGINX process — in background.
::
:start
start nginx
exit 0

::
:: Stop running NGINX process and clean.
::
:stop
if exist logs\nginx.pid ( nginx -s quit )
:: Clean NGINX logs to save some space.
if exist logs\*.log ( erase logs\*.log )
exit 0
