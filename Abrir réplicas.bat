@echo off
rem Abre as replicas do OnTopReplica. Edite a vontade: cada bloco "start" e uma replica.
rem Coordenadas de referencia: tela 1920x1009 (ajuste para a sua).
rem   --region   = x,y,largura,altura do pedaco da janela do Tibia a copiar
rem   --position = x,y onde a replica aparece na tela
rem   --size     = largura,altura da replica

rem Caminho do OnTopReplica: o ajudante preenche OTR_EXE; rodando o .bat sozinho, usa o padrao.
if not defined OTR_EXE set "OTR_EXE=C:\Program Files (x86)\OnTopReplica\OnTopReplica\OnTopReplica.exe"

rem Fecha as replicas abertas antes de reabrir
taskkill /F /IM OnTopReplica.exe >nul 2>&1

rem replica 1
start "" "%OTR_EXE%" ^
  --windowTitle="Tibia -" ^
  --region=1753,134,32,32 ^
  --position=787,431 ^
  --size=38,38 ^
  --chromeOff --clickThrough --opacity=179

rem replica 2
start "" "%OTR_EXE%" ^
  --windowTitle="Tibia -" ^
  --region=1753,206,32,32 ^
  --position=916,431 ^
  --size=38,38 ^
  --chromeOff --clickThrough --opacity=179

rem replica 3
start "" "%OTR_EXE%" ^
  --windowTitle="Tibia -" ^
  --region=912,675,140,32 ^
  --position=800,260 ^
  --size=147,34 ^
  --chromeOff --clickThrough --opacity=179

rem replica 4
start "" "%OTR_EXE%" ^
  --windowTitle="Tibia -" ^
  --region=1419,31,130,3 ^
  --position=787,408 ^
  --size=173,4 ^
  --chromeOff --clickThrough --opacity=179

exit