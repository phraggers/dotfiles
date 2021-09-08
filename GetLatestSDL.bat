@echo off
::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
:: AUTO UPDATE SDL2 LIBS (x64)
:: Phragware (2021)
::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

:: SDL2, SDL_image, SDL_mixer, SDL_net, SDL_ttf
:: get latest source and build
:: (and cleans up most of the test & debug junk)

:: requires Visual Studio (vcvarsall.bat, MSBuild.exe)
:: requires Git (in global path)
:: uses robocopy and xcopy 
:: (I think they are default in win10)

::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

:: User Variables ::

:: separate built modules from SDL2? (1=yes, 0=no)
set SeparateModules=0

:: Make sure vcvarsall.bat path is correct (do not remove quotes)
set VCVarsPath="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"

:: Toolset for VS2019 is 142. Change it here if using newer toolset (google is friend)
:: TODO: could also use "msbuild -tv:3.5" but I haven't checked the versions
set MSBuildToolset=142

:: 64/86 (86 IS UNTESTED.. I haven't checked what wants 'x86' or '32' or 'win32' etc. This is a TODO)
set Arch=64

::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
:: don't need to adjust anything below this line
::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

:: VCVars
call %VCVarsPath% x%Arch%

:: clean previous builds
if exist build rmdir /s /q build

:: output dirs
if '%SeparateModules%'=='1' (set OutputSDL2=build\SDL2) else (set OutputSDL2=build)
if '%SeparateModules%'=='1' (set OutputSDL_image=build\SDL_image) else (set OutputSDL_image=build)
if '%SeparateModules%'=='1' (set OutputSDL_mixer=build\SDL_mixer) else (set OutputSDL_mixer=build)
if '%SeparateModules%'=='1' (set OutputSDL_net=build\SDL_net) else (set OutputSDL_net=build)
if '%SeparateModules%'=='1' (set OutputSDL_ttf=build\SDL_ttf) else (set OutputSDL_ttf=build)

:: Get latest sources
if not exist SDL (git clone --recursive https://github.com/libsdl-org/SDL.git) else (pushd SDL && git pull && popd)
if not exist SDL_image (git clone --recursive https://github.com/libsdl-org/SDL_image.git) else (pushd SDL_image && git pull && popd)
if not exist SDL_mixer (git clone --recursive https://github.com/libsdl-org/SDL_mixer.git) else (pushd SDL_mixer && git pull && popd)
if not exist SDL_ttf (git clone --recursive https://github.com/libsdl-org/SDL_ttf.git) else (pushd SDL_ttf && git pull && popd)
if not exist SDL_net (git clone --recursive https://github.com/libsdl-org/SDL_net.git) else (pushd SDL_net && git pull && popd)

:: SDL2
msbuild SDL\VisualC\SDL.sln -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo  -verbosity:minimal
pushd SDL\VisualC\x%Arch%
for /r %%a in (*.lib) do xcopy "%%a" ..\..\..\%OutputSDL2%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" ..\..\..\%OutputSDL2%\bin\ /i /Y /C /Q
popd
robocopy SDL\include\ %OutputSDL2%\include\ /copyall /e /ns /nc /nfl /ndl /np /njh /njs

:: tell MSBuild where SDL2 deps are
set "INCLUDE=%~dp0%OutputSDL2%\include;%INCLUDE%"
set "LIB=%~dp0%OutputSDL2%\lib;%~dp0%OutputSDL2%\bin;%LIB%"
set UseEnv=true

:: SDL_image
msbuild SDL_image\VisualC\SDL_image.sln -t:SDL2_image -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo  -verbosity:minimal
pushd SDL_image\VisualC\x%Arch%
for /r %%a in (*.lib) do xcopy "%%a" ..\..\..\%OutputSDL_image%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" ..\..\..\%OutputSDL_image%\bin\ /i /Y /C /Q
popd
xcopy SDL_image\SDL_image.h %OutputSDL_image%\include\

:: SDL_mixer
msbuild SDL_mixer\VisualC\SDL_mixer.sln -t:SDL2_mixer -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo  -verbosity:minimal
pushd SDL_mixer\VisualC\x%Arch%
for /r %%a in (*.lib) do xcopy "%%a" ..\..\..\%OutputSDL_mixer%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" ..\..\..\%OutputSDL_mixer%\bin\ /i /Y /C /Q
popd
robocopy SDL_mixer\include\ %OutputSDL_mixer%\include\ /copyall /e /ns /nc /nfl /ndl /np /njh /njs

:: SDL_net (don't see the point, it hasn't been updated in 6+ years, but whatevs)
msbuild SDL_net\VisualC\SDL_net.sln -t:SDL2_net -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo  -verbosity:minimal
pushd SDL_net\VisualC\x%Arch%
for /r %%a in (*.lib) do xcopy "%%a" ..\..\..\%OutputSDL_net%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" ..\..\..\%OutputSDL_net%\bin\ /i /Y /C /Q
popd
xcopy SDL_net\SDL_net.h %OutputSDL_net%\include\

:: SDL_ttf
msbuild SDL_ttf\VisualC\SDL_ttf.sln -t:SDL2_ttf -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release -nologo  -verbosity:minimal
pushd SDL_ttf\VisualC\x%Arch%
for /r %%a in (*.lib) do xcopy "%%a" ..\..\..\%OutputSDL_ttf%\lib\ /i /Y /C /Q
for /r %%a in (*.dll) do xcopy "%%a" ..\..\..\%OutputSDL_ttf%\bin\ /i /Y /C /Q
popd
xcopy SDL_ttf\SDL_ttf.h %OutputSDL_ttf%\include\

pause