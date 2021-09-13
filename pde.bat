@::=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@:: Phragware
@:: Phraggers Dev Environment
@:: (c) Phragware 2021
@::=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

@echo off
cd /d %~dp0
title PDE [Phragware Development Environment]

:: startup
if exist %~dp0~%~n0%~x0 goto _Commands
if not exist %~dp0~%~n0%~x0 echo running>%~dp0~%~n0%~x0

:: %~dp0 this file dir
:: %~n0 this file name
:: %~x0 this file ext

:: User Directories
:: %homedrive%%homepath% / %userprofile% eg C:\Users\prbag
:: %appdata% eg C:\Users\prbag\AppData\Roaming

:: find vcvarsall
:: pushd c:\ && dir vcvarsall* /s /p /b && popd

:: Visual Studio Version
set VSVer=2019
set Arch=64

:: Git Version
set GitVerMaj=2
set GitVerMin=33

:: Emacs Version
set EmacsVerMaj=27
set EmacsVerMin=2

:: set Directories
set GitDir=%~dp0Programs\git
set EmacsDir=%~dp0Programs\emacs
set CppCheckDir=%~dp0Programs\cppcheck

:: set paths
set VSPath="C:\Program Files (x86)\Microsoft Visual Studio\%VSVer%\Community\VC\Auxiliary\Build"
set path=%~dp0Programs\Git\bin;%path%
set path=%~dp0Programs\Emacs\bin;%path%
set path=%~dp0Programs\cppcheck;%path%
set path=%~dp0;%path%

:: Run batch
call :_setESC
call :_setStyles
call :_EnvironmentSetup
goto _Exit

::=========
:: Styles
::=========
:_setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
  exit /b 0
)
:: F is foreground, B is background, 'SReset' to reset to default, 
:: eg: echo %SHighlight%Some Text%SReset%
:_SetStyles
set SReset=%ESC%[0m
set SHighlight=%ESC%[101;93m
set SUnderline=%ESC%[4m
set FDark=%ESC%[90m
set FRed=%ESC%[91m
set FGreen=%ESC%[92m
set FYellow=%ESC%[93m
set FBlue=%ESC%[94m
set FMagenta=%ESC%[95m
set FCyan=%ESC%[96m
set FWhite=%ESC%[97m
set BDark=%ESC%[100m
set BRed=%ESC%[101m
set BGreen=%ESC%[102m
set BYellow=%ESC%[103m
set BBlue=%ESC%[104m
set BMagenta=%ESC%[105m
set BCyan=%ESC%[106m
set BWhite=%ESC%[107m
color 07
set Line=echo %FDark%=%FRed%-%FGreen%=%FYellow%-%FBlue%=%FMagenta%-%FCyan%=%FWhite%-%FDark%=%FRed%-%FGreen%=%FYellow%-%FBlue%=%FMagenta%-%FCyan%=%FWhite%-%FDark%=%FRed%-%FGreen%=%FYellow%-%FBlue%=%FMagenta%-%FCyan%=%FWhite%-%FDark%=%FRed%-%FGreen%=%FYellow%-%FBlue%=%FMagenta%-%FCyan%=%FWhite%-%FDark%=%FRed%-%FGreen%=%SReset%
exit /b 0

::====================
:: Environment Setup
::====================
:_EnvironmentSetup
if not exist %~dp0Downloads mkdir %~dp0Downloads

explorer %~dp0

:: install VS
call :_e0
where /q %VSPath%:vcvarsall
if '%errorlevel%'=='1' call :_GetVSMenu

:: run vcvarsall
call "C:\Program Files (x86)\Microsoft Visual Studio\%VSVer%\Community\VC\Auxiliary\Build\vcvarsall.bat" x%Arch%

:: install git
call :_e0
where /q git
if '%errorlevel%'=='1' call :_GetGitMenu

:: install emacs
call :_e0
where /q emacs
if '%errorlevel%'=='1' call :_GetEmacsMenu

:: get pde.el
if not exist %~dp0Programs\pde.el call :_GetEmacsInit

:: setup commands
call :_PrintCommands

:: command line
echo.
echo %FRed%IMPORTANT: Please type 'exit' to exit, don't just close the window!%SReset%
echo.
call cmd

:: exit
del %~dp0~%~n0%~x0
subst /d w:
exit /b 0

::=============
:: Get VS Menu
::=============
:_GetVSMenu
:GetVSMenu_Start
call :_MainHeader
echo %FYellow%Get Visual Studio%SReset%
echo.
echo %FMagenta%Visual Studio must be installed to continue!%SReset%
echo Visual Studio must be installed manually.
echo.
echo 1. Get Visual Studio (Opens download link in default browser)
echo 0. Continue install PDE (when Visual Studio is installed)

echo.
if '%ChoiceError%'=='1' echo "%choice%" is not valid, try again!
set ChoiceError=
set choice=
set /p choice=Choice: 
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' goto GetVSMenu_1
if '%choice%'=='0' goto GetVSMenuCheck
set ChoiceError=1
echo.
goto GetVSMenu_Start

:GetVSMenu_1
start "" https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community
goto GetVSMenu_Start

:GetVSMenuCheck
call :_e0
where /q %VSPath%:vcvarsall
if '%errorlevel%'=='1' goto GetVSMenu_Start
exit /b 0

::===============
:: Get Git Menu
::===============
:_GetGitMenu
if not exist %~dp0Downloads mkdir %~dp0Downloads

call :_MainHeader
echo %FYellow%Get Git%SReset%
echo.
echo %FMagenta%Git must be installed to continue!%SReset%

echo.
echo Launching default browser to get Git.
echo Make sure to save file in %~dp0Downloads
start "" https://github.com/git-for-windows/git/releases/download/v%GitVerMaj%.%GitVerMin%.0.windows.1/PortableGit-%GitVerMaj%.%GitVerMin%.0-64-bit.7z.exe

explorer %~dp0Downloads
echo Continue when file is in %~dp0Downloads
pause

echo.
if not exist %~dp0Downloads\PortableGit-%GitVerMaj%.%GitVerMin%.0-64-bit.7z.exe goto GetEmacsHTTP_Error
if not exist %~dp0Programs\Git mkdir %~dp0Programs\Git
echo Press any key to launch GitPortable Extractor.
echo Please extract it to the following Directory:
echo %~dp0Programs\Git
echo|set/p=%~dp0Programs\Git|clip
echo.
echo The path has been copied to your clipboard,
echo so just press %FYellow%Ctrl + v%SReset% then %FYellow%Enter%SReset% in the Extractor.
pause
%~dp0Downloads\PortableGit-%GitVerMaj%.%GitVerMin%.0-64-bit.7z.exe
goto GetGitMenu_End

:GetGitMenu_Error
echo.
echo Can't find file %~dp0Downloads\PortableGit-%GitVerMaj%.%GitVerMin%.0-64-bit.7z.exe
echo Check file names and make sure the file is in the correct directory.
echo Press any key to retry download.
pause
goto GetGitMenu_1

:GetGitMenu_End
call :_e0
where /q git
if '%errorlevel%'=='1' goto GetGitMenu_Start
exit /b 0

::================
:: Get Emacs Menu
::================
:_GetEmacsMenu
if not exist %~dp0Downloads mkdir %~dp0Downloads

call :_MainHeader
echo %FYellow%Installing Emacs%SReset%
echo.
if not exist %~dp0Programs\Emacs mkdir %~dp0Programs\Emacs
dir /a /b %~dp0Programs\Emacs | findstr /r ".">NUL && goto GetEmacsMenuExists

if exist %~dp0Downloads\emacs-%EmacsVerMaj%.%EmacsVerMin%-x86_64.zip del /q %~dp0Downloads\emacs-%EmacsVerMaj%.%EmacsVerMin%-x86_64.zip
echo Downloading Emacs-%EmacsVerMaj%.%EmacsVerMin% ... %FMagenta%Please wait!%SReset%
pushd %~dp0Downloads
echo open ftp.gnu.org> TempGetEmacsScript.txt
echo anonymous>> TempGetEmacsScript.txt
echo get gnu/emacs/windows/emacs-%EmacsVerMaj%/emacs-%EmacsVerMaj%.%EmacsVerMin%-x86_64.zip>>TempGetEmacsScript.txt
echo quit>> TempGetEmacsScript.txt
ftp -s:TempGetEmacsScript.txt
del TempGetEmacsScript.txt
popd
echo %FGreen%Done!%SReset%

call :_MainHeader
echo %FYellow%Installing Emacs%SReset%
echo.
echo Download %FGreen%Complete!%SReset%
echo.
echo Extracting emacs-%EmacsVerMaj%\emacs-%EmacsVerMaj%.%EmacsVerMin%-x86_64.zip ... %FMagenta%Please wait!%SReset%
if not exist %~dp0Programs\Emacs mkdir %~dp0Programs\Emacs
tar -xf %~dp0Downloads\emacs-%EmacsVerMaj%.%EmacsVerMin%-x86_64.zip -C %~dp0Programs\Emacs
echo %FGreen%Done!%SReset%
echo.
goto GetEmacsMenu_End

:GetEmacsMenuExists
call :_e0
where /q emacs
if '%errorlevel%'=='0' goto GetEmacsMenu_End

echo %FYellow%DELETING%SReset% ... %FMagenta%Please wait!%SReset%
if exist %~dp0Programs\Emacs rmdir /s /q %~dp0Programs\Emacs && mkdir %~dp0Programs\Emacs
echo Done!
goto GetEmacsMenuContinue

:GetEmacsMenu_End
call :_e0
where /q emacs
if '%errorlevel%'=='1' goto GetEmacsMenu_1
exit /b 0

::================
:: Get Emacs Init
::================
:_GetEmacsInit
echo Downloading PDE emacs configuration...
pushd %~dp0Downloads
git clone https://github.com/phraggers/PDE.git
popd
copy %~dp0Downloads\PDE\pde.el %~dp0Programs\pde.el
exit /b 0

::==============
:: Main Header
::==============
:_MainHeader
cls
echo.
%Line%
echo %FCyan%Phraggers Dev Environment%SReset%
echo %FBlue%(Windows 10 64)%SReset%
%Line%
echo.
exit /b 0

::====================
:: Check Environment
::====================
:_CheckEnvironment
echo %FYellow%Environment:%SReset%
echo|set /p=" Last Checked: " & time /t

:: Visual Studio
call :_e0
where /q %VSPath%:vcvarsall
if '%errorlevel%'=='0' ( echo Visual Studio: %FGreen%Installed!%SReset% ) else ( echo Visual Studio: %FRed%Not Found!%SReset% )

:: Git
call :_e0
where /q git
if '%errorlevel%'=='0' ( echo Git: %FGreen%Installed!%SReset% ) else ( echo Git: %FRed%Not Found!%SReset% )

:: Emacs
call :_e0
where /q emacs
if '%errorlevel%'=='0' ( echo Emacs: %FGreen%Installed!%SReset% ) else ( echo Emacs: %FRed%Not Found!%SReset% )

echo.
exit /b 0

::=================
:: PrintCommands
::=================
:_PrintCommands
color
cls
call :_MainHeader
call :_CheckEnvironment
echo %FYellow% Some Commands:%SReset%
echo %FCyan% %~n0 emacs [file]%SReset% - starts up emacs with PDE config (file optional)
echo %FCyan% %~n0 project "name"%SReset% - Open/create project (name must be in quotes if there are spaces)
exit /b 0

::=============
:: Clear Error
::=============
:_e0
exit /b 0

::==========
:: Commands
::==========
:_Command_emacs
w:
start "" /b %~dp0Programs\Emacs\bin\emacs.exe -q -l %~dp0Programs\pde.el %2
exit /b 0

:_Command_project
if not exist %2 mkdir %2
subst w: %2
w:
exit /b 0

:_Commands
if '%1'=='emacs' call :_Command_emacs %~1 %~2
if '%1'=='project' call :_Command_project %~1 %~2

::========
:: Exit
::========
:_Exit
exit /b 0