@echo off
::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
:: AUTO UPDATE SDL2 LIBS (Win64-MSVC)
:: Phragware (2021)
::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

:: SDL2, SDL_image, SDL_mixer, SDL_net, SDL_ttf
:: get latest source and build
:: (and cleans up most of the test & debug junk)

:: requires Visual Studio (vcvarsall.bat, MSBuild.exe)
:: requires Git (in global path)
:: uses robocopy and xcopy (I think they are default in win10)

:: IMPORTANT: THIS BAT FILE SHOULD ONLY BE RUN IN
::            AN EMPTY DIRECTORY (for first use).
:: If there is a directory called "SDL" or something
:: that wasn't a git clone then this bat won't work
:: and might spew out some random files or delete your sys32 (jk)

:: Notes on updating existing files:
:: MSBuild only rebuilds when the source has changed (when git pulls updates)
:: ROBOCOPY will only replace updated files
:: XCOPY is set to always overwrite
:: It could probably be more efficient but it works fine for my purposes.

::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

:: User Variables ::

:: separate built modules from SDL2? (1=yes, 0=no)
set SeparateModules=0

:: Make sure vcvarsall.bat path is correct (do not remove quotes)
set VCVarsPath="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"

:: Toolset for VS2019 is 142. Change it here if using newer toolset (google is friend)
:: TODO: could also use "msbuild -tv:3.5" but I haven't checked the versions
set MSBuildToolset=142

::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
:: don't need to adjust anything below this line
::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

:: VCVars
call %VCVarsPath% x64

:: clean previous builds
:: commented out, I don't like using rmdir because stuff can get deleted unintentionally!
::if exist build rmdir /s /q build

:: output dirs
if '%SeparateModules%'=='1' (set OutputSDL2=%~dp0SDL2\build\SDL2) else (set OutputSDL2=%~dp0SDL2\build)
if '%SeparateModules%'=='1' (set OutputSDL_image=%~dp0SDL2\build\SDL_image) else (set OutputSDL_image=%~dp0SDL2\build)
if '%SeparateModules%'=='1' (set OutputSDL_mixer=%~dp0SDL2\build\SDL_mixer) else (set OutputSDL_mixer=%~dp0SDL2\build)
if '%SeparateModules%'=='1' (set OutputSDL_net=%~dp0SDL2\build\SDL_net) else (set OutputSDL_net=%~dp0SDL2\build)
if '%SeparateModules%'=='1' (set OutputSDL_ttf=%~dp0SDL2\build\SDL_ttf) else (set OutputSDL_ttf=%~dp0SDL2\build)

:: Get latest sources
:: TODO: if there's no .git folder inside the following directories then this doesn't work, 
:: eg if someone manually created the folder beforehand. This .bat should only run in an 
:: empty directory or where it has been run before.
:: I don't want to delete them (which would make sure this bat always works) because 
:: it could delete user data or whatever.

if not exist %~dp0SDL2 mkdir %~dp0SDL2

pushd SDL2

if not exist SDL (
	git clone --recursive https://github.com/libsdl-org/SDL.git
) else (
	pushd SDL
	git pull
	popd
)

if not exist SDL_image (
	git clone --recursive https://github.com/libsdl-org/SDL_image.git
) else (
	pushd SDL_image
	git pull
	popd
)

if not exist SDL_mixer (
	git clone --recursive https://github.com/libsdl-org/SDL_mixer.git
) else (
	pushd SDL_mixer
	git pull
	popd
)

if not exist SDL_ttf (
	git clone --recursive https://github.com/libsdl-org/SDL_ttf.git
) else (
	pushd SDL_ttf
	git pull
	popd
)

if not exist SDL_net (
	git clone --recursive https://github.com/libsdl-org/SDL_net.git
) else (
	pushd SDL_net
	git pull
	popd
)

popd

:: SDL2
msbuild %~dp0SDL2\SDL\VisualC\SDL.sln -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo -verbosity:minimal
pushd %~dp0SDL2\SDL\VisualC\x64
for /r %%a in (*.lib) do xcopy "%%a" %OutputSDL2%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" %OutputSDL2%\bin\ /i /Y /C /Q
popd
robocopy %~dp0SDL2\SDL\include\ %OutputSDL2%\include\ /copyall /e /ns /nc /nfl /ndl /np /njh /njs /is

:: tell MSBuild where SDL2 deps are
set "INCLUDE=%OutputSDL2%\include;%INCLUDE%"
set "LIB=%OutputSDL2%\lib;%OutputSDL2%\bin;%LIB%"
set UseEnv=true

:: SDL_image
msbuild %~dp0SDL2\SDL_image\VisualC\SDL_image.sln -t:SDL2_image -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo -verbosity:minimal
pushd %~dp0SDL2\SDL_image\VisualC\x64
for /r %%a in (*.lib) do xcopy "%%a" %OutputSDL_image%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" %OutputSDL_image%\bin\ /i /Y /C /Q
popd
xcopy %~dp0SDL2\SDL_image\SDL_image.h %OutputSDL_image%\include\ /i /Y /C /Q

:: SDL_mixer
msbuild %~dp0SDL2\SDL_mixer\VisualC\SDL_mixer.sln -t:SDL2_mixer -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo -verbosity:minimal
pushd %~dp0SDL2\SDL_mixer\VisualC\x64
for /r %%a in (*.lib) do xcopy "%%a" %OutputSDL_mixer%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" %OutputSDL_mixer%\bin\ /i /Y /C /Q
popd
robocopy %~dp0SDL2\SDL_mixer\include\ %OutputSDL_mixer%\include\ /copyall /e /ns /nc /nfl /ndl /np /njh /njs /is

:: SDL_net (don't see the point, it hasn't been updated in 6+ years, but whatevs)
msbuild %~dp0SDL2\SDL_net\VisualC\SDL_net.sln -t:SDL2_net -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo -verbosity:minimal
pushd %~dp0SDL2\SDL_net\VisualC\x64
for /r %%a in (*.lib) do xcopy "%%a" %OutputSDL_net%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" %OutputSDL_net%\bin\ /i /Y /C /Q
popd
xcopy %~dp0SDL2\SDL_net\SDL_net.h %OutputSDL_net%\include\ /i /Y /C /Q

:: SDL_ttf
msbuild %~dp0SDL2\SDL_ttf\VisualC\SDL_ttf.sln -t:SDL2_ttf -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo -verbosity:minimal
pushd %~dp0SDL2\SDL_ttf\VisualC\x64
for /r %%a in (*.lib) do xcopy "%%a" %OutputSDL_ttf%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" %OutputSDL_ttf%\bin\ /i /Y /C /Q
popd
xcopy %~dp0SDL2\SDL_ttf\SDL_ttf.h %OutputSDL_ttf%\include\ /i /Y /C /Q