@echo off
cd /d "%~dp0"
set GIT_AUTHOR_NAME=Xql.dev
set GIT_AUTHOR_EMAIL=205849173+KirobotDev@users.noreply.github.com
set GIT_COMMITTER_NAME=Xql.dev
set GIT_COMMITTER_EMAIL=205849173+KirobotDev@users.noreply.github.com
git add -A
for /f %%i in ('git write-tree') do set TREE=%%i
for /f %%i in ('git rev-parse HEAD') do set PARENT=%%i
for /f %%i in ('git commit-tree %TREE% -p %PARENT% -m "Add MIT license"') do set NEW=%%i
git update-ref refs/heads/main %NEW%
git log -1 --format=%%B
git push origin main
