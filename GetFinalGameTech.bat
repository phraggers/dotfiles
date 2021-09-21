@echo off
if not exist final_game_tech (
	git clone https://github.com/f1nalspace/final_game_tech.git
) else (
	pushd final_game_tech
	git pull
	popd
)
