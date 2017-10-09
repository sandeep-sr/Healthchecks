@echo off
if exist "exists.txt" del "exists.txt"
for /F %%server in (C:\temp\srv.txt) do (
  if exist "\\%%server\C$\windows\System32\WindowsPowerShell\v1.0\powershell.exe" (
    echo %%server : FOUND >>C:\temp\exists.txt
  ) else (
    echo %%server : MISSING >>C:\temp\exists.txt
  )
)