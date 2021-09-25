@echo off
if not exist imgui (
	git clone https://github.com/ocornut/imgui.git
) else (
	pushd imgui
	git pull
	popd
)
