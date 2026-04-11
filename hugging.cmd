@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

rem Hugging Face Space deploy (upload triggers rebuild on Docker Spaces)
rem Usage:
rem   hugging.cmd          deploy only if git has uncommitted changes, or new commits since last deploy
rem   hugging.cmd /f       force deploy always
rem Env:
rem   HF_SPACE             Space repo id (default: cristiefisherwfc43821s/facefusion-t4)
rem Automation:
rem   Task Scheduler: periodic run of hugging.cmd or hugging.cmd /f
rem   Git (Windows): .git\hooks\post-commit.cmd with: @call "%~dp0..\..\hugging.cmd"

if not defined HF_SPACE set "HF_SPACE=cristiefisherwfc43821s/facefusion-t4"

where hf >nul 2>&1
if errorlevel 1 (
	echo [hugging] hf CLI not found. Install: pip install -U "huggingface_hub[cli]"  ^&^&  hf auth login
	exit /b 1
)

set "FORCE=0"
if /i "%~1"=="/f" set "FORCE=1"
if /i "%~1"=="-f" set "FORCE=1"

if "!FORCE!"=="0" (
	git rev-parse --is-inside-work-tree >nul 2>&1
	if not errorlevel 1 (
		for /f "delims=" %%H in ('git rev-parse HEAD 2^>nul') do set "HF_HEAD=%%H"
		set "HF_LAST="
		if exist ".hf-deploy-sha" (
			for /f "usebackq delims=" %%L in (".hf-deploy-sha") do set "HF_LAST=%%L"
		)
		set "HF_DIRTY=0"
		for /f "delims=" %%P in ('git status --porcelain 2^>nul') do set "HF_DIRTY=1"
		if "!HF_DIRTY!"=="0" (
			if defined HF_LAST if "!HF_HEAD!"=="!HF_LAST!" (
				echo [hugging] No new work: same commit as last deploy ^(!HF_HEAD:~0,7!^). Run: hugging.cmd /f
				exit /b 0
			)
		)
	)
)

set "HF_MSG=hugging.cmd deploy"
git rev-parse --short HEAD >nul 2>&1
if not errorlevel 1 (
	for /f "delims=" %%S in ('git rev-parse --short HEAD 2^>nul') do set "HF_MSG=hugging.cmd deploy %%S"
)
echo [hugging] Uploading to spaces/!HF_SPACE! ...
hf upload "!HF_SPACE!" . --repo-type space ^
	--exclude ".git/**" ^
	--exclude ".venv-test/**" ^
	--exclude "**/__pycache__/**" ^
	--exclude ".specstory/**" ^
	--exclude ".pytest_cache/**" ^
	--exclude "@.txt" ^
	--exclude ".hf-deploy-sha" ^
	--commit-message "!HF_MSG!"

if errorlevel 1 (
	echo [hugging] Upload failed.
	exit /b 1
)

git rev-parse HEAD > ".hf-deploy-sha" 2>nul
echo [hugging] OK. Space will rebuild: https://huggingface.co/spaces/!HF_SPACE!
endlocal
exit /b 0
