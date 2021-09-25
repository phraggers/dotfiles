@echo off
if not exist stb (
	git clone https://github.com/nothings/stb.git
) else (
	pushd stb
	git pull
	popd
)
