# ow-blocker - portable Overwatch server blocker
# feito por jeanvga

$ErrorActionPreference = 'Stop'

# self-elevate
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`""
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$createdNew = $false
$appMutex = New-Object System.Threading.Mutex($true, 'Local\OWBlockerJeanvga', [ref]$createdNew)
if (-not $createdNew) {
    [System.Windows.Forms.MessageBox]::Show('OW Server Blocker ja esta aberto.', 'OW Server Blocker') | Out-Null
    exit
}

$GROUP = 'ow-blocker/jeanvga'
$CUSTOM_FILE = Join-Path $PSScriptRoot 'ow-blocker-custom.txt'

$GPC_ASIA_SOUTHEAST1   = '34.1.128.0/20,34.1.192.0/20,34.2.16.0/20,34.2.128.0/17,34.21.128.0/17,34.87.0.0/17,34.87.128.0/18,34.104.58.0/23,34.104.106.0/23,34.124.42.0/23,34.124.128.0/17,34.126.64.0/18,34.126.128.0/18,34.128.44.0/23,34.128.60.0/23,34.142.128.0/17,34.143.128.0/17,34.152.104.0/23,34.153.40.0/23,34.153.232.0/23,34.157.82.0/23,34.157.88.0/23,34.157.210.0/23,34.158.32.0/19,34.177.72.0/23,34.177.80.0/20,34.177.96.0/20,35.185.176.0/20,35.186.144.0/20,35.187.224.0/19,35.197.128.0/19,35.198.192.0/18,35.213.128.0/18,35.220.24.0/23,35.234.192.0/20,35.240.128.0/17,35.242.24.0/23,35.247.128.0/18,136.110.0.0/18,2600:1900:4080::/44'
$GPC_EUROPE_NORTH1     = '34.88.0.0/16,34.104.96.0/21,34.124.32.0/21,35.203.232.0/21,35.217.0.0/18,35.220.26.0/24,35.228.0.0/16,35.242.26.0/24,2600:1900:4150::/44'
$GPC_SOUTHAMERICA_EAST1= '34.39.128.0/17,34.95.128.0/17,34.104.80.0/21,34.124.16.0/21,34.151.0.0/18,34.151.192.0/18,35.198.0.0/18,35.199.64.0/18,35.215.192.0/18,35.220.40.0/24,35.235.0.0/20,35.242.40.0/24,35.247.192.0/18,2600:1900:40f0::/44'
$GPC_ASIA_NORTHEAST1   = '34.84.0.0/16,34.85.0.0/17,34.104.62.0/23,34.104.128.0/17,34.127.190.0/23,34.146.0.0/16,34.153.192.0/19,34.157.64.0/20,34.157.164.0/22,34.157.192.0/20,34.180.64.0/18,35.187.192.0/19,35.189.128.0/19,35.190.224.0/20,35.194.96.0/19,35.200.0.0/17,35.213.0.0/17,35.220.56.0/22,35.221.64.0/18,35.230.240.0/20,35.242.56.0/22,35.243.64.0/18,104.198.80.0/20,104.198.112.0/20,136.110.64.0/18,2600:1900:4050::/44'
$GPC_ME_CENTRAL2       = '8.228.192.0/19,8.230.64.0/19,34.1.48.0/20,34.152.84.0/23,34.152.102.0/24,34.157.122.128/25,34.157.218.128/25,34.166.0.0/16,34.177.48.0/23,34.177.70.0/24,35.252.32.0/19,2600:1900:5400::/44'
$GPC_US_EAST4          = '8.228.64.0/18,34.4.32.0/20,34.11.0.0/17,34.21.0.0/17,34.48.0.0/16,34.85.128.0/17,34.86.0.0/16,34.104.60.0/23,34.104.124.0/23,34.118.252.0/23,34.124.60.0/23,34.127.188.0/23,34.145.128.0/17,34.150.128.0/17,34.157.0.0/21,34.157.16.0/20,34.157.128.0/21,34.157.144.0/20,34.181.128.0/17,34.182.128.0/17,34.183.12.0/22,34.183.34.0/23,34.183.60.0/24,34.184.12.0/22,34.184.32.0/23,34.184.59.0/24,34.186.32.0/19,34.186.64.0/18,35.186.160.0/19,35.188.224.0/19,35.194.64.0/19,35.199.0.0/18,35.212.0.0/17,35.220.60.0/22,35.221.0.0/18,35.230.160.0/19,35.234.176.0/20,35.236.192.0/18,35.242.60.0/22,35.243.40.0/21,35.245.0.0/16,136.107.0.0/16,2600:1900:4090::/44'
$BLIZZARD_DACOM_KR     = '110.45.208.0/24,117.52.6.0/24,117.52.26.0/23,117.52.28.0/23,117.52.33.0/24,117.52.34.0/23,117.52.36.0/23,121.254.137.0/24,121.254.206.0/23,121.254.218.0/24,182.162.31.0/24'

$regions = @(
    [pscustomobject]@{ Name = 'Brazil (GBR1)';         Ips = $GPC_SOUTHAMERICA_EAST1;            BaseIps = $GPC_SOUTHAMERICA_EAST1;        Ping = '34.39.128.0';  GcpScope = 'southamerica-east1'; Default = $true  }
    [pscustomobject]@{ Name = 'USA - Central (ORD1)';  Ips = '64.224.0.0/21,24.105.40.0/21';     BaseIps = '64.224.0.0/21,24.105.40.0/21'; Ping = '8.34.210.23';  GcpScope = $null;                Default = $false }
    [pscustomobject]@{ Name = 'USA - East (GUE4)';     Ips = $GPC_US_EAST4;                      BaseIps = $GPC_US_EAST4;                  Ping = '8.228.65.52';  GcpScope = 'us-east4';           Default = $false }
    [pscustomobject]@{ Name = 'USA - West (LAS1)';     Ips = '64.224.24.0/23';                   BaseIps = '64.224.24.0/23';               Ping = '34.16.128.42'; GcpScope = $null;                Default = $false }
    [pscustomobject]@{ Name = 'Netherlands (AMS1)';    Ips = '64.224.26.0/23';                   BaseIps = '64.224.26.0/23';               Ping = '137.221.78.60';GcpScope = $null;                Default = $true  }
    [pscustomobject]@{ Name = 'Finland (GEN1)';        Ips = $GPC_EUROPE_NORTH1;                 BaseIps = $GPC_EUROPE_NORTH1;             Ping = '34.88.0.1';    GcpScope = 'europe-north1';      Default = $true  }
    [pscustomobject]@{ Name = 'Singapore (GSG1)';      Ips = $GPC_ASIA_SOUTHEAST1;               BaseIps = $GPC_ASIA_SOUTHEAST1;           Ping = '34.1.128.4';   GcpScope = 'asia-southeast1';    Default = $true  }
    [pscustomobject]@{ Name = 'Tokyo (GTK1)';          Ips = $GPC_ASIA_NORTHEAST1;               BaseIps = $GPC_ASIA_NORTHEAST1;           Ping = '34.84.0.0';    GcpScope = 'asia-northeast1';    Default = $true  }
    [pscustomobject]@{ Name = 'South Korea (ICN1)';    Ips = $BLIZZARD_DACOM_KR;                 BaseIps = $BLIZZARD_DACOM_KR;             Ping = '34.64.64.15';  GcpScope = 'asia-northeast3';    Default = $true  }
    [pscustomobject]@{ Name = 'Taiwan (TPE1)';         Ips = '5.42.160.0/22,5.42.164.0/22';      BaseIps = '5.42.160.0/22,5.42.164.0/22';  Ping = '34.80.0.0';    GcpScope = 'asia-east1';         Default = $true  }
    [pscustomobject]@{ Name = 'Australia (SYD2)';      Ips = '158.115.196.0/23';                 BaseIps = '158.115.196.0/23';             Ping = '34.40.128.34'; GcpScope = 'australia-southeast1'; Default = $true  }
    [pscustomobject]@{ Name = 'Saudi Arabia (GMEC2)';  Ips = $GPC_ME_CENTRAL2;                   BaseIps = $GPC_ME_CENTRAL2;               Ping = '34.166.0.84';  GcpScope = 'me-central2';        Default = $true  }
)

function Cleanup-Rules {
    try {
        Get-NetFirewallRule -Group $GROUP -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
    } catch {}
    try {
        Get-NetFirewallRule -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Direction -eq 'Outbound' -and
                $_.Action -eq 'Block' -and
                (
                    $_.DisplayName -like 'ow-block:*' -or
                    $_.DisplayName -eq 'Overwatch NA'
                )
            } |
            Remove-NetFirewallRule -ErrorAction SilentlyContinue
    } catch {}
}

function Get-PingIpMap {
    $map = @{}
    foreach ($r in $regions) {
        if ($r.Ping) { $map[$r.Ping] = $true }
    }
    return $map
}

function Test-RemoteAddressToken {
    param([string]$Address)

    if (-not $Address) { return $false }

    $parts = $Address -split '/', 2
    $ipPart = $parts[0]
    $parsed = [System.Net.IPAddress]::None
    if (-not [System.Net.IPAddress]::TryParse($ipPart, [ref]$parsed)) {
        return $false
    }

    if ($parts.Count -eq 1) { return $true }

    $prefix = 0
    if (-not [int]::TryParse($parts[1], [ref]$prefix)) {
        return $false
    }

    if ($parsed.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) {
        return ($prefix -ge 0 -and $prefix -le 32)
    }

    return ($prefix -ge 0 -and $prefix -le 128)
}

function Get-CustomAddresses {
    param([string]$Text)

    $pingIps = Get-PingIpMap
    $unique = [ordered]@{}
    if (-not $Text) { return @() }

    foreach ($line in ($Text -split "(`r`n|`n|`r)")) {
        $lineNoComment = $line -replace '#.*$', ''
        foreach ($token in ($lineNoComment -split '[,\s]+')) {
            $addr = $token.Trim()
            if (-not $addr) { continue }
            if ($pingIps.ContainsKey($addr)) { continue }
            if (-not (Test-RemoteAddressToken $addr)) { continue }
            if (-not $unique.Contains($addr)) { $unique[$addr] = $true }
        }
    }

    return @($unique.Keys)
}

function Format-CustomAddresses {
    param([string]$Text)

    $items = @(Get-CustomAddresses $Text)
    if ($items.Count -eq 0) { return '' }
    return ($items -join "`r`n")
}

function Convert-CapturedIpToBlockAddress {
    param([string]$Ip)

    if (-not $Ip) { return $null }

    # Blizzard rotates OW match hosts inside small 137.221.x.x pools. Blocking
    # only one host often misses the next lobby, so keep capture additions at /24.
    if ($Ip -match '^137\.221\.(\d{1,3})\.\d{1,3}$') {
        return "137.221.$($Matches[1]).0/24"
    }

    return $Ip
}

function Get-CaptureBlockAddresses {
    param($Groups)

    $unique = [ordered]@{}
    foreach ($g in @($Groups)) {
        $addr = Convert-CapturedIpToBlockAddress $g.Name
        if (-not $addr) { continue }
        if (-not (Test-RemoteAddressToken $addr)) { continue }
        if (-not $unique.Contains($addr)) { $unique[$addr] = $true }
    }

    return @($unique.Keys)
}

function Load-CustomIps {
    try {
        if (Test-Path -LiteralPath $CUSTOM_FILE) {
            return (Get-Content -Raw -LiteralPath $CUSTOM_FILE)
        }
    } catch {}

    return ''
}

function Save-CustomIps {
    param([string]$Text)

    try {
        $clean = Format-CustomAddresses $Text
        Set-Content -LiteralPath $CUSTOM_FILE -Value $clean -Encoding ASCII
        return $clean
    } catch {
        return $Text
    }
}

function Apply-Block {
    param($selected, $customIps)
    Cleanup-Rules
    foreach ($r in $selected) {
        $addrs = $r.Ips -split ','
        New-NetFirewallRule `
            -DisplayName ("ow-block: " + $r.Name) `
            -Group $GROUP `
            -Direction Outbound `
            -Action Block `
            -Profile Any `
            -RemoteAddress $addrs `
            -ErrorAction SilentlyContinue | Out-Null
    }
    if ($customIps) {
        $custom = @(Get-CustomAddresses $customIps)
        if ($custom.Count -gt 0) {
            New-NetFirewallRule `
                -DisplayName 'ow-block: custom' `
                -Group $GROUP `
                -Direction Outbound `
                -Action Block `
                -Profile Any `
                -RemoteAddress $custom `
                -ErrorAction SilentlyContinue | Out-Null
        }
    }
}

function Count-Active {
    (Get-NetFirewallRule -Group $GROUP -ErrorAction SilentlyContinue | Measure-Object).Count
}

function Update-GcpFromInternet {
    try {
        $json = Invoke-RestMethod -Uri 'https://www.gstatic.com/ipranges/cloud.json' -TimeoutSec 10
        $byScope = @{}
        foreach ($p in $json.prefixes) {
            $s = $p.scope
            if (-not $byScope.ContainsKey($s)) { $byScope[$s] = New-Object System.Collections.Generic.List[string] }
            if ($p.ipv4Prefix) { $byScope[$s].Add($p.ipv4Prefix) }
            elseif ($p.ipv6Prefix) { $byScope[$s].Add($p.ipv6Prefix) }
        }
        $updated = 0
        foreach ($r in $regions) {
            if ($r.GcpScope -and $byScope.ContainsKey($r.GcpScope)) {
                $gcpJoined = ($byScope[$r.GcpScope] -join ',')
                if ($r.BaseIps) {
                    $r.Ips = $r.BaseIps + ',' + $gcpJoined
                } else {
                    $r.Ips = $gcpJoined
                }
                $updated++
            }
        }
        return $updated
    } catch {
        return -1
    }
}

function Get-OwUdpPorts {
    $procs = @(Get-Process -Name 'Overwatch' -ErrorAction SilentlyContinue | Sort-Object Id -Unique)
    if ($procs.Count -eq 0) { return @() }

    $ports = @()
    foreach ($p in $procs) {
        $ports += Get-NetUDPEndpoint -OwningProcess $p.Id -ErrorAction SilentlyContinue |
                  Where-Object { $_.LocalPort } |
                  ForEach-Object { [int]$_.LocalPort }
    }

    return @($ports | Sort-Object -Unique)
}

function Capture-OwUdp {
    param([int]$Seconds = 10)

    $oldEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    try {
        $owUdpPorts = @(Get-OwUdpPorts)

        if (-not (Get-Command pktmon -ErrorAction SilentlyContinue)) {
            return @{ Error = 'pktmon nao encontrado no PATH (Windows 10 1809+ ou Win11)' }
        }

        $tmpEtl = Join-Path $env:TEMP ("owblk-" + [guid]::NewGuid().ToString().Substring(0,8) + ".etl")
        $tmpTxt = [System.IO.Path]::ChangeExtension($tmpEtl, '.txt')

        # ensure clean state
        & pktmon stop *>&1 | Out-Null
        & pktmon filter remove *>&1 | Out-Null

        $addOut = & pktmon filter add -p UDP *>&1 | Out-String

        # try Win11 syntax first, then legacy
        $startOut = & pktmon start --capture --pkt-size 64 -f $tmpEtl *>&1 | Out-String
        Start-Sleep -Milliseconds 500
        if (-not (Test-Path $tmpEtl)) {
            & pktmon stop *>&1 | Out-Null
            $startOut2 = & pktmon start --etw --pkt-size 64 -f $tmpEtl *>&1 | Out-String
            Start-Sleep -Milliseconds 500
        }

        if (-not (Test-Path $tmpEtl)) {
            & pktmon filter remove *>&1 | Out-Null
            return @{ Error = "pktmon start falhou.`n--capture: $startOut`n--etw: $startOut2" }
        }

        Start-Sleep -Seconds $Seconds

        & pktmon stop *>&1 | Out-Null
        & pktmon filter remove *>&1 | Out-Null

        # format - try modern then legacy command
        $fmtOut = & pktmon format $tmpEtl -o $tmpTxt *>&1 | Out-String
        if (-not (Test-Path $tmpTxt)) {
            $fmtOut2 = & pktmon etl2txt $tmpEtl -o $tmpTxt *>&1 | Out-String
        }
        if (-not (Test-Path $tmpTxt)) {
            Remove-Item $tmpEtl -ErrorAction SilentlyContinue
            return @{ Error = "Falha ao formatar.`nformat: $fmtOut`netl2txt: $fmtOut2" }
        }

        $content = Get-Content $tmpTxt -Raw
        Remove-Item $tmpEtl, $tmpTxt -ErrorAction SilentlyContinue

        if (-not $content) {
            return @{ Error = 'Captura vazia (verifique se o OW estava em partida)' }
        }

        $scanContent = $content
        $filteredByPorts = $false
        if ($owUdpPorts.Count -gt 0) {
            $portPattern = (($owUdpPorts | ForEach-Object { [regex]::Escape($_.ToString()) }) -join '|')
            $portLines = @($content -split "(`r`n|`n|`r)" | Where-Object { $_ -match "(^|[^0-9])($portPattern)([^0-9]|$)" })
            if ($portLines.Count -gt 0) {
                $scanContent = ($portLines -join "`n")
                $filteredByPorts = $true
            }
        }

        # extract IPs broadly, then filter to public only
        $rgx = [regex]'\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b'
        $rawIps = @()
        foreach ($m in $rgx.Matches($scanContent)) { $rawIps += $m.Groups[1].Value }
        if ($rawIps.Count -eq 0 -and $filteredByPorts) {
            $filteredByPorts = $false
            foreach ($m in $rgx.Matches($content)) { $rawIps += $m.Groups[1].Value }
        }

        # exclude our own ping target IPs (background runspace noise)
        $ownPingIps = @{}
        foreach ($r in $regions) { $ownPingIps[$r.Ping] = $true }

        $public = $rawIps | Where-Object {
            if ($ownPingIps.ContainsKey($_)) {
                $false
            } elseif ($_ -match '^(\d+)\.(\d+)\.\d+\.\d+$') {
                $a = [int]$Matches[1]; $b = [int]$Matches[2]
                -not (
                    ($a -eq 10) -or ($a -eq 127) -or ($a -eq 0) -or
                    ($a -eq 192 -and $b -eq 168) -or
                    ($a -eq 172 -and $b -ge 16 -and $b -le 31) -or
                    ($a -ge 224) -or
                    ($a -eq 169 -and $b -eq 254)
                )
            } else {
                $false
            }
        }

        $grouped = $public | Group-Object | Sort-Object Count -Descending | Select-Object -First 30
        return @{ Top = $grouped; Total = $rawIps.Count; UdpPorts = $owUdpPorts; FilteredByPorts = $filteredByPorts }
    } finally {
        $ErrorActionPreference = $oldEAP
    }
}

function Get-OwConnections {
    $procs = @(Get-Process -Name 'Overwatch' -ErrorAction SilentlyContinue | Sort-Object Id -Unique)
    if ($procs.Count -eq 0) {
        return $null
    }
    $result = @(
        'TCP mostra conexoes remotas. UDP listen mostra so portas locais; use "Capturar UDP" para achar IP remoto.'
        ''
    )
    foreach ($p in $procs) {
        $conns = Get-NetTCPConnection -OwningProcess $p.Id -ErrorAction SilentlyContinue |
                 Where-Object { $_.RemoteAddress -and $_.RemoteAddress -ne '0.0.0.0' -and $_.RemoteAddress -ne '::' -and $_.RemoteAddress -notmatch '^127\.' }
        foreach ($c in $conns) {
            $result += "$($p.ProcessName) [TCP $($c.State)]  $($c.RemoteAddress):$($c.RemotePort)"
        }
        $udp = Get-NetUDPEndpoint -OwningProcess $p.Id -ErrorAction SilentlyContinue
        foreach ($u in $udp) {
            $result += "$($p.ProcessName) [UDP listen]  local:$($u.LocalAddress):$($u.LocalPort)"
        }
    }
    return $result
}

# Keep Google-hosted region ranges current when the machine can reach gstatic.
[void](Update-GcpFromInternet)

# shared ping state
$sync = [hashtable]::Synchronized(@{})
foreach ($r in $regions) { $sync[$r.Name] = '...' }

$pingTargets = @()
foreach ($r in $regions) {
    $pingTargets += [pscustomobject]@{ Name = $r.Name; Ip = $r.Ping }
}

# background runspace pings continuously
$rs = [runspacefactory]::CreateRunspace()
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()
$rs.SessionStateProxy.SetVariable('sync', $sync)
$rs.SessionStateProxy.SetVariable('targets', $pingTargets)

$ps = [powershell]::Create()
$ps.Runspace = $rs
[void]$ps.AddScript({
    $p = New-Object System.Net.NetworkInformation.Ping
    while ($true) {
        foreach ($t in $targets) {
            try {
                $reply = $p.Send($t.Ip, 1500)
                if ($reply.Status -eq 'Success') {
                    $sync[$t.Name] = "$($reply.RoundtripTime) ms"
                } else {
                    $sync[$t.Name] = 'timeout'
                }
            } catch {
                $sync[$t.Name] = '-'
            }
        }
        Start-Sleep -Milliseconds 800
    }
})
$handle = $ps.BeginInvoke()

# Remove regras antigas caso o app anterior tenha sido fechado pela tela preta/processo.
Cleanup-Rules

# form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'OW Server Blocker'
$form.Size = New-Object System.Drawing.Size(500, 810)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 28)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

$header = New-Object System.Windows.Forms.Label
$header.Text = 'Marque os servidores para BLOQUEAR'
$header.Location = New-Object System.Drawing.Point(20, 12)
$header.Size = New-Object System.Drawing.Size(460, 22)
$header.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($header)

$hint = New-Object System.Windows.Forms.Label
$hint.Text = 'MARCADO = bloqueado (nao joga la)   |   DESMARCADO = liberado'
$hint.Location = New-Object System.Drawing.Point(20, 36)
$hint.Size = New-Object System.Drawing.Size(460, 18)
$hint.ForeColor = [System.Drawing.Color]::Silver
$form.Controls.Add($hint)

$y = 64
$checkboxes = @{}
$pingLabels = @{}
foreach ($r in $regions) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $r.Name
    $cb.Location = New-Object System.Drawing.Point(28, $y)
    $cb.Size = New-Object System.Drawing.Size(290, 24)
    $cb.Checked = $r.Default
    $cb.ForeColor = [System.Drawing.Color]::White
    $form.Controls.Add($cb)
    $checkboxes[$r.Name] = $cb

    $pl = New-Object System.Windows.Forms.Label
    $pl.Text = '...'
    $pl.Location = New-Object System.Drawing.Point(330, ($y + 4))
    $pl.Size = New-Object System.Drawing.Size(140, 20)
    $pl.TextAlign = 'MiddleRight'
    $pl.Font = New-Object System.Drawing.Font('Consolas', 9, [System.Drawing.FontStyle]::Bold)
    $pl.ForeColor = [System.Drawing.Color]::Silver
    $form.Controls.Add($pl)
    $pingLabels[$r.Name] = $pl

    $y += 28
}

$y += 10

$status = New-Object System.Windows.Forms.Label
$status.Text = 'Status: desbloqueado'
$status.Location = New-Object System.Drawing.Point(20, $y)
$status.Size = New-Object System.Drawing.Size(460, 22)
$status.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$status.ForeColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($status)
$y += 28

$btnBlock = New-Object System.Windows.Forms.Button
$btnBlock.Text = 'Aplicar bloqueio'
$btnBlock.Location = New-Object System.Drawing.Point(20, $y)
$btnBlock.Size = New-Object System.Drawing.Size(220, 36)
$btnBlock.FlatStyle = 'Flat'
$btnBlock.BackColor = [System.Drawing.Color]::FromArgb(200, 50, 50)
$btnBlock.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($btnBlock)

$btnUnblock = New-Object System.Windows.Forms.Button
$btnUnblock.Text = 'Desbloquear tudo'
$btnUnblock.Location = New-Object System.Drawing.Point(250, $y)
$btnUnblock.Size = New-Object System.Drawing.Size(220, 36)
$btnUnblock.FlatStyle = 'Flat'
$btnUnblock.BackColor = [System.Drawing.Color]::FromArgb(50, 130, 80)
$btnUnblock.ForeColor = [System.Drawing.Color]::White
$btnUnblock.Add_Click({
    Cleanup-Rules
    $status.Text = 'Status: desbloqueado'
    $status.ForeColor = [System.Drawing.Color]::LightGreen
})
$form.Controls.Add($btnUnblock)
$y += 46

$btnDiag = New-Object System.Windows.Forms.Button
$btnDiag.Text = 'Ver conexoes do OW'
$btnDiag.Location = New-Object System.Drawing.Point(20, $y)
$btnDiag.Size = New-Object System.Drawing.Size(220, 30)
$btnDiag.FlatStyle = 'Flat'
$btnDiag.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 70)
$btnDiag.ForeColor = [System.Drawing.Color]::White
$btnDiag.Add_Click({
    $conns = Get-OwConnections
    if ($null -eq $conns) {
        [System.Windows.Forms.MessageBox]::Show('Overwatch nao esta aberto.', 'Diagnostico') | Out-Null
        return
    }
    if ($conns.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('Sem conexoes ativas.', 'Diagnostico') | Out-Null
        return
    }
    $w = New-Object System.Windows.Forms.Form
    $w.Text = 'Conexoes do Overwatch'
    $w.Size = New-Object System.Drawing.Size(560, 420)
    $w.StartPosition = 'CenterParent'
    $w.BackColor = [System.Drawing.Color]::FromArgb(24,24,28)
    $w.ForeColor = [System.Drawing.Color]::White
    $tb = New-Object System.Windows.Forms.TextBox
    $tb.Multiline = $true
    $tb.ReadOnly = $true
    $tb.ScrollBars = 'Vertical'
    $tb.Font = New-Object System.Drawing.Font('Consolas', 9)
    $tb.Dock = 'Fill'
    $tb.BackColor = [System.Drawing.Color]::FromArgb(18,18,22)
    $tb.ForeColor = [System.Drawing.Color]::LightGreen
    $tb.Text = ($conns -join "`r`n")
    $w.Controls.Add($tb)
    [void]$w.ShowDialog()
})
$form.Controls.Add($btnDiag)

$btnCapture = New-Object System.Windows.Forms.Button
$btnCapture.Text = 'Capturar UDP OW (15s)'
$btnCapture.Location = New-Object System.Drawing.Point(250, $y)
$btnCapture.Size = New-Object System.Drawing.Size(220, 30)
$btnCapture.FlatStyle = 'Flat'
$btnCapture.BackColor = [System.Drawing.Color]::FromArgb(80, 60, 110)
$btnCapture.ForeColor = [System.Drawing.Color]::White
$btnCapture.Add_Click({
    if (-not (Get-Process -Name 'Overwatch' -ErrorAction SilentlyContinue)) {
        [System.Windows.Forms.MessageBox]::Show('Abra o Overwatch e entre numa partida primeiro.', 'Aviso') | Out-Null
        return
    }
    $btnCapture.Enabled = $false
    $btnCapture.Text = 'Capturando UDP (15s)...'
    $form.Refresh()
    $r = Capture-OwUdp -Seconds 15
    $btnCapture.Enabled = $true
    $btnCapture.Text = 'Capturar UDP OW (15s)'

    if ($r.Error) {
        [System.Windows.Forms.MessageBox]::Show($r.Error, 'Erro') | Out-Null
        return
    }
    if (-not $r.Top -or $r.Top.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Nenhum IP capturado.`nTotal de pacotes UDP: $($r.Total)", 'Captura') | Out-Null
        return
    }

    $w = New-Object System.Windows.Forms.Form
    $w.Text = 'IPs UDP capturados (top destinos)'
    $w.Size = New-Object System.Drawing.Size(560, 480)
    $w.StartPosition = 'CenterParent'
    $w.BackColor = [System.Drawing.Color]::FromArgb(24,24,28)
    $w.ForeColor = [System.Drawing.Color]::White

    $tb = New-Object System.Windows.Forms.TextBox
    $tb.Multiline = $true
    $tb.ReadOnly = $true
    $tb.ScrollBars = 'Vertical'
    $tb.Font = New-Object System.Drawing.Font('Consolas', 10)
    $tb.Location = New-Object System.Drawing.Point(10, 10)
    $tb.Size = New-Object System.Drawing.Size(525, 360)
    $tb.BackColor = [System.Drawing.Color]::FromArgb(18,18,22)
    $tb.ForeColor = [System.Drawing.Color]::LightGreen
    $portText = if ($r.UdpPorts -and $r.UdpPorts.Count -gt 0) { ($r.UdpPorts -join ', ') } else { 'nao detectadas' }
    $modeText = if ($r.FilteredByPorts) { 'filtrado pelas portas UDP do OW' } else { 'captura geral UDP' }
    $lines = @("Modo: $modeText")
    $lines += "Portas UDP OW: $portText"
    $lines += ''
    $lines += 'Pacotes  IP destino'
    $lines += '------------------------'
    foreach ($g in $r.Top) {
        $lines += ("{0,7}  {1}" -f $g.Count, $g.Name)
    }
    $suggestedBlocks = @(Get-CaptureBlockAddresses $r.Top)
    if ($suggestedBlocks.Count -gt 0) {
        $lines += ''
        $lines += 'Ranges sugeridos para bloquear'
        $lines += '------------------------------'
        $lines += $suggestedBlocks
    }
    $tb.Text = ($lines -join "`r`n")
    $w.Controls.Add($tb)

    $btnCopy = New-Object System.Windows.Forms.Button
    $btnCopy.Text = 'Adicionar ranges sugeridos ao custom e aplicar'
    $btnCopy.Location = New-Object System.Drawing.Point(10, 380)
    $btnCopy.Size = New-Object System.Drawing.Size(525, 36)
    $btnCopy.FlatStyle = 'Flat'
    $btnCopy.BackColor = [System.Drawing.Color]::FromArgb(120, 60, 60)
    $btnCopy.ForeColor = [System.Drawing.Color]::White
    $btnCopy.Add_Click({
        $newIps = (Get-CaptureBlockAddresses $r.Top) -join "`r`n"
        $txtCustom.Text = Format-CustomAddresses (($txtCustom.Text, $newIps) -join "`r`n")
        [void](Save-CustomIps $txtCustom.Text)
        $selected = $regions | Where-Object { $checkboxes[$_.Name].Checked }
        Apply-Block $selected $txtCustom.Text
        $n = Count-Active
        $status.Text = "Status: BLOQUEADO ($n regras ativas)"
        $status.ForeColor = [System.Drawing.Color]::Tomato
        $w.Close()
    })
    $w.Controls.Add($btnCopy)

    [void]$w.ShowDialog()
})
$form.Controls.Add($btnCapture)
$y += 40
$y += 40

$lblCustom = New-Object System.Windows.Forms.Label
$lblCustom.Text = 'IPs/CIDRs custom (use so IP UDP de partida; auth/CDN pode quebrar login):'
$lblCustom.Location = New-Object System.Drawing.Point(20, $y)
$lblCustom.Size = New-Object System.Drawing.Size(460, 18)
$lblCustom.ForeColor = [System.Drawing.Color]::Silver
$form.Controls.Add($lblCustom)
$y += 20

$txtCustom = New-Object System.Windows.Forms.TextBox
$txtCustom.Multiline = $true
$txtCustom.ScrollBars = 'Vertical'
$txtCustom.Location = New-Object System.Drawing.Point(20, $y)
$txtCustom.Size = New-Object System.Drawing.Size(450, 60)
$txtCustom.Font = New-Object System.Drawing.Font('Consolas', 9)
$txtCustom.BackColor = [System.Drawing.Color]::FromArgb(18,18,22)
$txtCustom.ForeColor = [System.Drawing.Color]::White
$txtCustom.Text = Load-CustomIps
$form.Controls.Add($txtCustom)
$y += 70

$btnBlock.Add_Click({
    $selected = $regions | Where-Object { $checkboxes[$_.Name].Checked }
    $custom = Save-CustomIps $txtCustom.Text
    $txtCustom.Text = $custom
    $customList = @(Get-CustomAddresses $custom)
    if ($selected.Count -eq 0 -and $customList.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('Marque pelo menos um servidor ou adicione IPs custom.', 'Aviso') | Out-Null
        return
    }
    Apply-Block $selected $custom
    $n = Count-Active
    $status.Text = "Status: BLOQUEADO ($n regras ativas)"
    $status.ForeColor = [System.Drawing.Color]::Tomato
})

$footer = New-Object System.Windows.Forms.Label
$footer.Text = 'feito por jeanvga'
$footer.Location = New-Object System.Drawing.Point(20, $y)
$footer.Size = New-Object System.Drawing.Size(460, 20)
$footer.TextAlign = 'MiddleCenter'
$footer.ForeColor = [System.Drawing.Color]::Gray
$footer.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Italic)
$form.Controls.Add($footer)
$y += 22

$note = New-Object System.Windows.Forms.Label
$note.Text = 'Ao fechar a janela, todas as regras sao removidas automaticamente.'
$note.Location = New-Object System.Drawing.Point(20, $y)
$note.Size = New-Object System.Drawing.Size(460, 18)
$note.TextAlign = 'MiddleCenter'
$note.ForeColor = [System.Drawing.Color]::Silver
$form.Controls.Add($note)

# UI timer reads ping results from sync hashtable
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500
$timer.Add_Tick({
    foreach ($r in $regions) {
        $val = $sync[$r.Name]
        $lbl = $pingLabels[$r.Name]
        if ($val -ne $lbl.Text) {
            $lbl.Text = $val
            if ($val -match '^(\d+) ms$') {
                $ms = [int]$Matches[1]
                if     ($ms -lt 60)  { $lbl.ForeColor = [System.Drawing.Color]::LightGreen }
                elseif ($ms -lt 120) { $lbl.ForeColor = [System.Drawing.Color]::Khaki }
                elseif ($ms -lt 200) { $lbl.ForeColor = [System.Drawing.Color]::Orange }
                else                  { $lbl.ForeColor = [System.Drawing.Color]::Tomato }
            } else {
                $lbl.ForeColor = [System.Drawing.Color]::Gray
            }
        }
    }
})
$timer.Start()

$form.Add_FormClosing({
    Cleanup-Rules
    try { $timer.Stop() } catch {}
    try { $ps.Stop() } catch {}
    try { $rs.Close() } catch {}
    try { [void](Save-CustomIps $txtCustom.Text) } catch {}
    Cleanup-Rules
})

try {
    [void]$form.ShowDialog()
} finally {
    Cleanup-Rules
    try { $timer.Stop() } catch {}
    try { $ps.Stop() } catch {}
    try { $rs.Close() } catch {}
    try { [void](Save-CustomIps $txtCustom.Text) } catch {}
    Cleanup-Rules
    try { if ($appMutex) { $appMutex.ReleaseMutex(); $appMutex.Dispose() } } catch {}
}
