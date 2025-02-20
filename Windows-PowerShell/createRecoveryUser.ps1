# --------------------------------------------------------------------------------
# ------------------------------------- VARIABLES --------------------------------
# --------------------------------------------------------------------------------
$SERVICE_NAME = "APPLICATIONOS"
$PROCESS_NAME = "APPLICATION.Suite.Services.SingleProcess"
$APPLICATION_URL = "http://localhost:5000/shell/"
$USERNAME = $null
$PASSWORD = $null
$WAIT_COUNTER = 0
$FAILURE_COUNTER = 0
$RETRY_LIMIT = 5

function GET_SERVICE_STATUS {
    return Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
}

function KILL_PROCESS {
    Write-Host "CHECKING FOR EXISTING PROCESSES USING PORT 5000..."
    $PROCESS = Get-Process -Name $PROCESS_NAME -ErrorAction SilentlyContinue
    if ($PROCESS) {
        Stop-Process -Id $PROCESS.Id -Force
        Write-Host "PROCESS STOPPED: $($PROCESS.Id)" -ForegroundColor Red
    } 
    else {
        Write-Output "NONE FOUND."
    }
}

# --------------------------------------------------------------------------------
# ------------------------------------- MAIN -------------------------------------
# --------------------------------------------------------------------------------
# stopping APPLICATIONOS
Clear-Host
Write-Host "----------------------------------------------------------" -ForegroundColor Magenta
Write-Host "SCRIPT START."
Write-Host "STOPPING THE $SERVICE_NAME SERVICE..."

while ($true) {
    Stop-Service -Name $SERVICE_NAME -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    $CheckServiceStatus = GET_SERVICE_STATUS
    if ($CheckServiceStatus.Status -eq "Running") {
        Write-Host "$SERVICE_NAME FAILED TO STOP. EXITING..." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "$SERVICE_NAME STOPPED!" -ForegroundColor Red
        break
    }
}

# --------------------------------------------------------------------------------
# check single process pid & kill if exists
KILL_PROCESS

# Start the process and capture output in real-time
Write-Host "RUNNING (./APPLICATION.Suite.Services.SingleProcess repair=True) IN ORDER TO RETRIEVE RECOVERY CREDENTIALS."
$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$proc.StartInfo.FileName = "C:\Program Files\APPLICATION\os\$PROCESS_NAME.exe"
$proc.StartInfo.Arguments = "repair=True"
$proc.StartInfo.RedirectStandardOutput = $true
$proc.StartInfo.UseShellExecute = $false
$proc.StartInfo.CreateNoWindow = $true  # Prevents new window
$null = $proc.Start()  # This suppresses the return value

# Listen to output stream for credentials
Write-Host "PROCESS RUNNING! LISTENING FOR CREDENTIALS..."
while (-not $proc.StandardOutput.EndOfStream) {
    $line = $proc.StandardOutput.ReadLine()
    $WAIT_COUNTER++
    if ($line -match "Username:\s*(\S+)") {
        $USERNAME = $matches[1]
    }
    if ($line -match "Password:\s*(\S+)") {
        $PASSWORD = $matches[1]
    }
    if ($USERNAME -and $PASSWORD) {
        Write-Host "CREDENTIALS FOUND!" -ForegroundColor Green
        break
    }
    if ($WAIT_COUNTER -gt 10) {
        Write-Host "PLEASE WAIT..."
        $WAIT_COUNTER = 0
    }
}

# kill output stream
if (!$proc.HasExited) {
    $proc.Kill()
}

# --------------------------------------------------------------------------------
# display credentials

Write-Host "------ RECOVERY USER ------" -ForegroundColor Yellow
Write-Output "USERNAME: $USERNAME"
Write-Output "PASSWORD: $PASSWORD"
Write-Host "-----------------------------" -ForegroundColor Yellow

# --------------------------------------------------------------------------------
# Start APPLICATIONOS again

Write-Host "STARTING THE $SERVICE_NAME SERVICE..."
while ($true) {
    Start-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    $CheckServiceStatus = GET_SERVICE_STATUS
    if ($CheckServiceStatus.Status -eq "Running") {
        Write-Host "$SERVICE_NAME STARTED SUCCESSFULLY!" -ForegroundColor Green
        Write-Host "OPENING APPLICATION IN A NEW WINDOW..."
        Start-Process $APPLICATION_URL
        Write-Host "SCRIPT COMPLETE."
        Write-Host "----------------------------------------------------------" -ForegroundColor Magenta
        exit 1
    } else {
        if ($FAILURE_COUNTER -gt $RETRY_LIMIT) {
            Write-Host "$SERVICE_NAME FAILED TO START. EXITING..." -ForegroundColor Red
            exit 1
        }
        Write-Host "$SERVICE_NAME FAILED TO START. RETRYING..." -ForegroundColor Red
        Write-Host "TRIES: $FAILURE_COUNTER/$RETRY_LIMIT"
        $FAILURE_COUNTER++
    }
}

exit 1