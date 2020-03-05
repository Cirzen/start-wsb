
# Serial Package List
$PrePackages = @(
    "powershell-core"
)

# Parallel package list. Multiple items within nested arrays will be installed serially
$Packages = @(
    @("docker-cli"),
    @("vscode",	"vscode-powershell"),
    @("notepadplusplus"),
    @("conemu"),
    @("firefox"),
    @("git"),
    @("procexp")
)
Write-Verbose "Starting stopwatch..." -Verbose
$Timer = [System.Diagnostics.Stopwatch]::StartNew()

# This fixes an issue with the extended type system wrapping the array entries with Value and Count properties.
# Required for interoperability with 5.1 and 7
# See https://stackoverflow.com/questions/20848507
Remove-TypeData System.Array

Set-ExecutionPolicy Bypass -Scope Process -Force
# Engages TLS 1.2, required for chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install the initial package (PS7) so we can run Foreach-Object in parallel...
foreach ($pkg in $PrePackages)
{
    cinst $pkg -y
}
# Ensure the path environment variable is up to date
refreshenv

# These are run in parallel
$7Script = {
    param(
        # A Json string of an array of an array of strings (object[string[]])
        [string]
        $Packages)
    # Restore the string back to the array
    $PackageObject = $Packages | ConvertFrom-Json
    Write-Debug -Message ($PackageObject | ConvertTo-Json) -Verbose
    $PackageObject | ForEach-Object -Parallel { Foreach ($p in $_) { cinst $p -y --no-progress } } -ThrottleLimit 2
}

$FilePath = (resolve-path "C:\Program Files\PowerShell\*\pwsh.exe").Path
$PackageJson = ($Packages) | ConvertTo-Json
& $FilePath -noprofile -nologo -command $7Script -args $PackageJson


Write-Verbose "Script completed in $(($Timer.Elapsed).ToString("hh\hmm\mss\s").TrimStart("00h").TrimStart("00m"))" -Verbose
Start-Sleep -Seconds 30