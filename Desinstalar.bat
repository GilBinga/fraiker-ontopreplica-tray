@echo off
rem Desinstala o Fraiker Tools: fecha o ajudante e as replicas, apaga os atalhos e os arquivos do ajudante.
rem Ficam a pasta e o "Abrir réplicas.bat" (o seu layout).
chcp 65001 >nul
setlocal
set "DIR=%~dp0"

rem Trava: so roda na pasta do Fraiker Tools, para nao apagar arquivos de outra pasta
if not exist "%DIR%Fraiker Tools.ps1" (
  echo Este desinstalador precisa estar na pasta do Fraiker Tools, junto do "Fraiker Tools.ps1".
  echo Nada foi apagado.
  pause
  exit /b
)

echo Fraiker Tools - desinstalação
echo.
echo Vai fechar o ajudante e as réplicas, apagar os atalhos "Fraiker Tools"
echo (Menu Iniciar, Área de Trabalho, pasta e Iniciar com o Windows) e os arquivos do ajudante.
echo A pasta e o "Abrir réplicas.bat" ficam.
echo.
choice /c SN /n /m "Desinstalar o Fraiker Tools? (S/N) "
if errorlevel 2 (
  echo Nada foi apagado.
  pause
  exit /b
)

echo.
echo Fechando o ajudante e as réplicas...
rem O padrao p[s]1 evita que este proprio comando se encontre na busca
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'powershell.exe' -and $_.CommandLine -like '*Fraiker Tools.p[s]1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"
taskkill /F /IM OnTopReplica.exe >nul 2>&1
ping -n 2 127.0.0.1 >nul

echo Apagando os atalhos...
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "'Startup','Desktop','Programs' | ForEach-Object { [Environment]::GetFolderPath($_) }"`) do (
  del /f /q "%%P\Fraiker Tools.lnk" >nul 2>&1
)
del /f /q "%DIR%Fraiker Tools.lnk" >nul 2>&1

echo Apagando os arquivos do ajudante...
for %%F in ("Fraiker Tools.ps1" "Fraiker Tools.vbs" "README.md" "LICENSE" ".gitattributes" ".gitignore") do (
  del /f /q "%DIR%%%~F" >nul 2>&1
)
rmdir /s /q "%DIR%assets" >nul 2>&1

echo.
echo Pronto. Ficaram a pasta e o "Abrir réplicas.bat".
echo O OnTopReplica é outro programa: desinstale pelo Windows, se quiser.
echo Se sobrar um ícone perto do relógio, ele some ao passar o mouse.
echo.
pause
rem Apaga este proprio arquivo
(goto) 2>nul & del /f /q "%~f0"
