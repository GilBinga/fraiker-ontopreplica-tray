# Ajudante OnTopReplica: icone perto do relogio, abre/esconde/fecha as replicas.
# Duplo clique no icone alterna: abre se fechadas, fecha se abertas.
# Esconder = marcar a janela como "janela de ferramenta" (sai da barra e do Alt-Tab).
# Layout das replicas: edite "Abrir réplicas.bat" nesta pasta.

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class OTR {
    delegate bool EnumProc(IntPtr h, IntPtr l);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc cb, IntPtr l);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] static extern IntPtr GetWindow(IntPtr h, uint cmd);
    [DllImport("user32.dll")] static extern int GetWindowLong(IntPtr h, int i);
    [DllImport("user32.dll")] static extern int SetWindowLong(IntPtr h, int i, int v);
    [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int c);

    const int GWL_EXSTYLE = -20;
    const int WS_EX_TOOLWINDOW = 0x80;
    const int WS_EX_APPWINDOW = 0x40000;
    const uint GW_OWNER = 4;
    const int SW_HIDE = 0;
    const int SW_SHOWNA = 8;

    static List<IntPtr> Windows() {
        var pids = new HashSet<uint>();
        foreach (var p in Process.GetProcessesByName("OnTopReplica")) pids.Add((uint)p.Id);
        var list = new List<IntPtr>();
        EnumProc cb = (h, l) => {
            uint pid;
            GetWindowThreadProcessId(h, out pid);
            if (pids.Contains(pid) && IsWindowVisible(h) && GetWindow(h, GW_OWNER) == IntPtr.Zero) list.Add(h);
            return true;
        };
        EnumWindows(cb, IntPtr.Zero);
        GC.KeepAlive(cb);
        return list;
    }

    // hide=true: tira da barra e do Alt-Tab; hide=false: devolve. Retorna quantas mudou.
    public static int Apply(bool hide) {
        int n = 0;
        foreach (var h in Windows()) {
            int ex = GetWindowLong(h, GWL_EXSTYLE);
            // Compara com o estilo final: o OnTopReplica pode religar WS_EX_APPWINDOW, que
            // mantem o botao na barra mesmo com WS_EX_TOOLWINDOW ligado.
            int nex = hide ? ((ex | WS_EX_TOOLWINDOW) & ~WS_EX_APPWINDOW) : (ex & ~WS_EX_TOOLWINDOW);
            if (nex == ex) continue;
            ShowWindow(h, SW_HIDE);
            SetWindowLong(h, GWL_EXSTYLE, nex);
            ShowWindow(h, SW_SHOWNA);
            n++;
        }
        return n;
    }
}
'@

# Uma instancia so
$mutex = New-Object System.Threading.Mutex($false, 'Local\OnTopReplicaTray')
if (-not $mutex.WaitOne(0)) { exit }

$dir = $PSScriptRoot
$bat = Join-Path $dir 'Abrir réplicas.bat'
# Acha o OnTopReplica.exe. Ordem: variavel OTR_EXE, processo aberto,
# pasta do ajudante, pastas de instalacao comuns.
function Find-OnTopReplica {
    if ($env:OTR_EXE -and (Test-Path $env:OTR_EXE)) { return $env:OTR_EXE }
    $p = Get-Process OnTopReplica -ErrorAction SilentlyContinue | Where-Object Path | Select-Object -First 1
    if ($p) { return $p.Path }
    $roots = @($dir, ${env:ProgramFiles(x86)}, $env:ProgramFiles, (Join-Path $env:LOCALAPPDATA 'Programs')) | Where-Object { $_ }
    foreach ($r in $roots) {
        $direct = Join-Path $r 'OnTopReplica.exe'
        if (Test-Path $direct) { return $direct }
        $folder = Join-Path $r 'OnTopReplica'
        if (Test-Path $folder) {
            $f = Get-ChildItem $folder -Filter OnTopReplica.exe -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($f) { return $f.FullName }
        }
    }
    return $null
}

$exe = Find-OnTopReplica

$tray = New-Object System.Windows.Forms.NotifyIcon
$ico = Join-Path $dir 'assets\fraiker-tools.ico'
if (Test-Path $ico) { $tray.Icon = New-Object System.Drawing.Icon($ico, [System.Windows.Forms.SystemInformation]::SmallIconSize) }
elseif ($exe) { $tray.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exe) }
else { $tray.Icon = [System.Drawing.SystemIcons]::Application }
$tray.Text = 'Fraiker Tools'

function Show-Tip($msg) { $tray.ShowBalloonTip(2000, 'Fraiker Tools', $msg, [System.Windows.Forms.ToolTipIcon]::Info) }

# Iniciar com o Windows = atalho "Fraiker Tools" na pasta Inicializar
$launcher = Join-Path $dir 'Fraiker Tools.vbs'
$startupLnk = Join-Path ([Environment]::GetFolderPath('Startup')) 'Fraiker Tools.lnk'
$desktopLnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Fraiker Tools.lnk'
$programsLnk = Join-Path ([Environment]::GetFolderPath('Programs')) 'Fraiker Tools.lnk'
$folderLnk = Join-Path $dir 'Fraiker Tools.lnk'

# Atalho "Fraiker Tools" com o icone do escudo (o .vbs nao aceita icone proprio)
function Set-Shortcut([string]$path, [bool]$on) {
    if ($on) {
        $sc = (New-Object -ComObject WScript.Shell).CreateShortcut($path)
        $sc.TargetPath = Join-Path $env:WINDIR 'System32\wscript.exe'
        $sc.Arguments = "`"$launcher`""
        $sc.WorkingDirectory = $dir
        $sc.Description = 'Fraiker Tools'
        if (Test-Path $ico) { $sc.IconLocation = "$ico,0" }
        $sc.Save()
    } else {
        Remove-Item $path -ErrorAction SilentlyContinue
    }
}
# Sempre: atalho na pasta do ajudante e no Menu Iniciar (recriados, caso a pasta mude de lugar)
try { Set-Shortcut $folderLnk $true; Set-Shortcut $programsLnk $true } catch {}
# Opcionais: so atualizam se ja existirem
foreach ($l in $startupLnk, $desktopLnk) { if (Test-Path $l) { try { Set-Shortcut $l $true } catch {} } }

# Depois de abrir: por ~10 s, esconde as janelas que forem aparecendo
$script:ticks = 0
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500
$timer.add_Tick({
    [void][OTR]::Apply($true)
    $script:ticks++
    if ($script:ticks -ge 20) { $timer.Stop() }
})

# Confere se o .bat so tem comandos de layout (rem, taskkill, timeout, start do OnTopReplica, exit).
# Retorna as linhas fora do padrao. Nos valores das opcoes nao pode haver & | < > % ^, que
# permitiriam esconder outro comando dentro de uma linha de aparencia normal.
function Get-UnsafeLines([string]$text) {
    $val = '("[^"&|<>%^]*"|[^\s"&|<>%^]+)'
    $opt = "--[A-Za-z][A-Za-z0-9]*(=$val)?"
    $exeArg = '"(%OTR_EXE%|[^"&|<>%^]*\\OnTopReplica\.exe)"'
    $redir = '(\s+(>nul|2>nul|2>&1))*'
    $ok = @(
        '^@echo\s+off$'
        '^rem(\s[^&|<>^]*)?$'
        "^taskkill\s+/F\s+/IM\s+OnTopReplica\.exe$redir$"
        "^timeout\s+/t\s+\d+(\s+/nobreak)?$redir$"
        '^exit(\s+/b)?(\s+\d+)?$'
        "^start\s+`"`"\s+$exeArg(\s+$opt)*$"
    )
    $bad = @()
    $logical = @()
    $cur = ''
    foreach ($l in (($text -replace "`r", '') -split "`n")) {
        if ($l -match '\^\s*$') {
            # Continuacao (^ no fim) so vale para o start e as linhas de opcoes
            if ($cur -eq '' -and $l.Trim() -notmatch '^start\s') { $bad += $l.Trim(); continue }
            $cur += ($l -replace '\^\s*$', ' ')
            continue
        }
        $logical += ($cur + $l)
        $cur = ''
    }
    if ($cur) { $logical += $cur }
    foreach ($l in $logical) {
        $t = ($l -replace '\s+', ' ').Trim()
        if ($t -eq '') { continue }
        $match = $false
        foreach ($re in $ok) { if ($t -match $re) { $match = $true; break } }
        if (-not $match) { $bad += $t }
    }
    return $bad
}

function Open-Replicas {
    if (-not (Test-Path $bat)) { Show-Tip 'Não achei "Abrir réplicas.bat" na pasta do ajudante.'; return }
    if (-not $exe) { $script:exe = Find-OnTopReplica }
    if (-not $exe) { Show-Tip 'Não achei o OnTopReplica.exe. Instale-o ou defina a variável OTR_EXE.'; return }
    $env:OTR_EXE = $exe   # o .bat herda e usa este caminho
    # O gerador do site as vezes escreve %%OTR_EXE%% (escapado demais), que no .bat vira texto literal.
    # Conserta o arquivo no disco antes de rodar.
    try { $txt = [IO.File]::ReadAllText($bat) } catch { Show-Tip 'Não consegui ler o "Abrir réplicas.bat".'; return }
    $fix = [regex]::Replace($txt, '%{2,}OTR_EXE%{2,}', '%OTR_EXE%')
    if ($fix -ne $txt) { try { [IO.File]::WriteAllText($bat, $fix, (New-Object Text.UTF8Encoding($false))) } catch {} }
    # Comandos fora do padrao de layout: pergunta antes de rodar (padrao: Nao)
    $unsafe = @(Get-UnsafeLines $fix)
    if ($unsafe.Count) {
        $list = ($unsafe | Select-Object -First 5 | ForEach-Object { if ($_.Length -gt 90) { $_.Substring(0, 90) + '...' } else { $_ } }) -join "`n"
        if ($unsafe.Count -gt 5) { $list += "`n(e mais $($unsafe.Count - 5))" }
        $msg = "O ""Abrir réplicas.bat"" tem comandos fora do padrão de um layout:`n`n$list`n`nSó rode se você sabe o que esses comandos fazem.`nRodar mesmo assim?"
        $r = [System.Windows.Forms.MessageBox]::Show($msg, 'Fraiker Tools', 'YesNo', 'Warning', 'Button2')
        if ($r -ne [System.Windows.Forms.DialogResult]::Yes) { return }
    }
    # Diretorio de trabalho fora da pasta do ajudante, para as replicas nao prenderem a pasta
    Start-Process -FilePath $bat -WorkingDirectory (Split-Path $exe) -WindowStyle Hidden
    $script:ticks = 0
    $timer.Start()
}

# Alterna: fecha se houver alguma replica rodando, abre se nao houver nenhuma
function Switch-Replicas {
    $running = Get-Process OnTopReplica -ErrorAction SilentlyContinue
    if ($running) {
        $timer.Stop()
        $running | Stop-Process -Force
    } else {
        Open-Replicas
    }
}

$menu = New-Object System.Windows.Forms.ContextMenuStrip
function Add-Item($text, [scriptblock]$action) {
    $item = $menu.Items.Add($text)
    $item.add_Click($action)
    return $item
}

$open = Add-Item 'Abrir / fechar réplicas' { Switch-Replicas }
$open.Font = New-Object System.Drawing.Font($open.Font, [System.Drawing.FontStyle]::Bold)
[void](Add-Item 'Mostrar réplicas na barra' { $timer.Stop(); $n = [OTR]::Apply($false); Show-Tip "$n janela(s) de volta na barra." })
[void](Add-Item 'Esconder réplicas da barra' { $n = [OTR]::Apply($true); Show-Tip "$n janela(s) escondida(s)." })
[void]$menu.Items.Add('-')
# Gerador de .bat feito pelo Porfz (creditos tambem no README)
$layoutUrl = 'https://claude.ai/artifact/6xc44YsEzGBxsgnZK54y6F'
[void](Add-Item 'Configurar layout (site do Porfz)' {
    try { Start-Process $layoutUrl } catch {}
    Show-Tip 'Monte o layout no site, copie o .bat e cole em "Editar script de abrir".'
})
[void](Add-Item 'Editar script de abrir' { Start-Process notepad.exe -ArgumentList "`"$bat`"" })
$auto = Add-Item 'Iniciar com o Windows' {
    Set-Shortcut $startupLnk (-not (Test-Path $startupLnk))
    $auto.Checked = Test-Path $startupLnk
}
$auto.Checked = Test-Path $startupLnk
$desk = Add-Item 'Atalho na Área de Trabalho' {
    Set-Shortcut $desktopLnk (-not (Test-Path $desktopLnk))
    $desk.Checked = Test-Path $desktopLnk
}
$desk.Checked = Test-Path $desktopLnk
[void]$menu.Items.Add('-')
$apoio = Add-Item 'Apoie o desenvolvedor: doe TCs para Fraiker' {
    try { [System.Windows.Forms.Clipboard]::SetText('Fraiker') } catch {}
    Show-Tip 'Nome "Fraiker" copiado. Para doar: Store do Tibia > Transfer Coins. Obrigado!'
}
$apoio.ForeColor = [System.Drawing.Color]::FromArgb(200, 130, 20)
[void]$menu.Items.Add('-')
[void](Add-Item 'Sair do ajudante' {
    $timer.Stop()
    Get-Process OnTopReplica -ErrorAction SilentlyContinue | Stop-Process -Force
    $tray.Visible = $false
    [System.Windows.Forms.Application]::Exit()
})

$tray.ContextMenuStrip = $menu
$tray.add_DoubleClick({ Switch-Replicas })
$tray.Visible = $true

[System.Windows.Forms.Application]::Run()

$tray.Dispose()
$mutex.ReleaseMutex()
