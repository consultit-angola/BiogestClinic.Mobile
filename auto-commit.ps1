param(
    [Parameter(Position = 0)]
    [string]$Message,

    [switch]$PullFromTest
)

$dartPath = Join-Path $PSScriptRoot '.fvm\flutter_sdk\bin\dart.bat'
$scriptPath = Join-Path $PSScriptRoot 'tool\auto_commit.dart'

if (-not (Test-Path -LiteralPath $dartPath)) {
    Write-Error 'FVM Dart SDK was not found. Run "fvm install" first.'
    exit 1
}

$branch = git -C $PSScriptRoot branch --show-current
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
    Write-Error 'Could not detect the current Git branch.'
    exit 1
}

$arguments = @(
    'run'
    $scriptPath
    "--branch=$branch"
    "--repo-path=$PSScriptRoot"
)

if (-not [string]::IsNullOrWhiteSpace($Message)) {
    $arguments += "--msg=$Message"
}

if ($PullFromTest) {
    $arguments += '--pull-from-test'
}

& $dartPath @arguments
exit $LASTEXITCODE
