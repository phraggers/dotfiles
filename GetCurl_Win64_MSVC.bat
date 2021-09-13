@echo off
::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
:: AUTO UPDATE CURL & ZLIB (Win64-MSVC)
:: Phragware (2021)
::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

:: requires Git (in global path)
:: uses robocopy (I think default in win10)

::-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

:: vcpkg
if not exist vcpkg (
	git clone https://github.com/microsoft/vcpkg
) else (
	pushd vcpkg
	git pull
	popd
)

:: vcpkg > curl (Not sure how to check if updated so just copy files every time)
set VCPKG_DEFAULT_TRIPLET=x64-windows
call vcpkg\bootstrap-vcpkg.bat
call vcpkg\vcpkg integrate install
call vcpkg\vcpkg install curl[tool]
robocopy vcpkg\installed\x64-windows\ build\ /copyall /e /ns /nc /nfl /ndl /np /njh /njs /is

pause