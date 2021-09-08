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

:: Make sure vcvarsall.bat path is correct (do not remove quotes)
set VCVarsPath="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"

:: Toolset for VS2019 is 142. Change it here if using newer toolset (google is friend)
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

:: Get latest source
if not exist SDL (git clone --recursive https://github.com/libsdl-org/SDL.git) else (pushd SDL && git pull && popd)
if not exist SDL_image (git clone --recursive https://github.com/libsdl-org/SDL_image.git) else (pushd SDL_image && git pull && popd)
if not exist SDL_mixer (git clone --recursive https://github.com/libsdl-org/SDL_mixer.git) else (pushd SDL_mixer && git pull && popd)
if not exist SDL_ttf (git clone --recursive https://github.com/libsdl-org/SDL_ttf.git) else (pushd SDL_ttf && git pull && popd)
if not exist SDL_net (git clone --recursive https://github.com/libsdl-org/SDL_net.git) else (pushd SDL_net && git pull && popd)

:: Build SDL2
msbuild SDL\VisualC\SDL.sln -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release
robocopy SDL\VisualC\x%Arch%\Release\ build\SDL2\bin\ /copyall /e
robocopy SDL\include\ build\SDL2\include\ /copyall /e
del build\SDL2\bin\*.exe build\SDL2\bin\*.ilk build\SDL2\bin\*.pdb build\SDL2\bin\*.exp

:: tell MSBuild where SDL2 deps are
set "INCLUDE=%~dp0build\SDL2\include;%INCLUDE%"
set "LIB=%~dp0build\SDL2\bin;%LIB%"
set UseEnv=true

:: Build SDL_image
msbuild SDL_image\VisualC\SDL_image.sln -t:SDL2_image -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release
robocopy SDL_image\VisualC\x%Arch%\Release\ build\SDL_image\bin\ /copyall /e
xcopy SDL_image\SDL_image.h build\SDL_image\include\
del build\SDL_image\bin\*.exe build\SDL_image\bin\*.ilk build\SDL_image\bin\*.pdb build\SDL_image\bin\*.exp build\SDL_image\bin\*.obj build\SDL_image\bin\*.res build\SDL_image\bin\*.recipe build\SDL_image\bin\*.txt
rmdir /s /q build\SDL_image\bin\SDL2_image.tlog\

:: Build SDL_mixer
msbuild SDL_mixer\VisualC\SDL_mixer.sln -t:SDL2_mixer -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release
robocopy SDL_mixer\VisualC\x%Arch%\Release\ build\SDL_mixer\bin\ /copyall /e
robocopy SDL_mixer\include\ build\SDL_mixer\include\ /copyall /e
del build\SDL_mixer\bin\*.exe build\SDL_mixer\bin\*.ilk build\SDL_mixer\bin\*.pdb build\SDL_mixer\bin\*.exp build\SDL_mixer\bin\*.obj build\SDL_mixer\bin\*.res build\SDL_mixer\bin\*.recipe build\SDL_mixer\bin\*.txt
rmdir /s /q build\SDL_mixer\bin\SDL2_mixer.tlog

:: Build SDL_net (don't see the point, it hasn't been updated in 6+ years, but whatevs)
msbuild SDL_net\VisualC\SDL_net.sln -t:SDL2_net -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release
robocopy SDL_net\VisualC\x%Arch%\Release\ build\SDL_net\bin\ /copyall /e
xcopy SDL_net\SDL_net.h build\SDL_net\include\
del build\SDL_net\bin\*.exe build\SDL_net\bin\*.ilk build\SDL_net\bin\*.pdb build\SDL_net\bin\*.exp build\SDL_net\bin\*.obj build\SDL_net\bin\*.res build\SDL_net\bin\*.recipe build\SDL_net\bin\*.txt
rmdir /s /q build\SDL_net\bin\SDL2_net.tlog

:: Build SDL_ttf
msbuild SDL_ttf\VisualC\SDL_ttf.sln -t:SDL2_ttf -p:PlatformToolset=v%MSBuildToolset%;Configuration=Release
robocopy SDL_ttf\VisualC\x%Arch%\Release\ build\SDL_ttf\bin\ /copyall /e
xcopy SDL_ttf\SDL_ttf.h build\SDL_ttf\include\
del build\SDL_ttf\bin\*.exe build\SDL_ttf\bin\*.ilk build\SDL_ttf\bin\*.pdb build\SDL_ttf\bin\*.exp build\SDL_ttf\bin\*.obj build\SDL_ttf\bin\*.res build\SDL_ttf\bin\*.recipe build\SDL_ttf\bin\*.txt
rmdir /s /q build\SDL_ttf\bin\SDL2_ttf.tlog

pause