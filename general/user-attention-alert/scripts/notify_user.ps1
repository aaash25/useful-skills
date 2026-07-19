[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Message,

    [ValidateRange(1, 5)]
    [int]$Repeat = 3,

    [ValidateRange(1, 60)]
    [int]$IntervalSeconds = 5,

    [switch]$DryRun
)

$spokenMessage = $Message.Trim()
if ($spokenMessage.Length -gt 120) {
    $spokenMessage = $spokenMessage.Substring(0, 120)
}

if ($DryRun) {
    Write-Output "notify_user dry-run: repeat=$Repeat interval=$IntervalSeconds message=$spokenMessage"
    exit 0
}

$synthesizer = $null
try {
    Add-Type -AssemblyName System.Speech -ErrorAction Stop
    $synthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $synthesizer.Rate = 0
    $synthesizer.Volume = 100
} catch {
    $synthesizer = $null
}

try {
    for ($attempt = 1; $attempt -le $Repeat; $attempt++) {
        try {
            [System.Media.SystemSounds]::Exclamation.Play()
        } catch {
            [console]::Beep(880, 300)
        }

        if ($null -ne $synthesizer) {
            try {
                $synthesizer.Speak($spokenMessage)
            } catch {
                [console]::Beep(1047, 300)
            }
        } else {
            [console]::Beep(1047, 300)
        }

        if ($attempt -lt $Repeat) {
            Start-Sleep -Seconds $IntervalSeconds
        }
    }
} finally {
    if ($null -ne $synthesizer) {
        $synthesizer.Dispose()
    }
}
