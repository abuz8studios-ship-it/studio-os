@echo off
setlocal
cmd.exe /c "netstat -ano | findstr :8188 >nul" || start "ComfyUI GPU" cmd.exe /k .\ComfyUI\run_comfyui_network.bat
timeout /t 8 /nobreak >nul
cmd.exe /c "netstat -ano | findstr :29212 >nul" || start "Studio MVP Server" cmd.exe /k wsl.exe -d Ubuntu-24.04 bash -lc "exec /mnt/e/ABU/StudioOS/bin/studio-mvp-server.sh"
timeout /t 4 /nobreak >nul
start "" http://127.0.0.1:29212/
exit /b 0
