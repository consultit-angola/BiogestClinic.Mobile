param(
    [Parameter(Position = 0)]
    [string]$Branch
)

$repositoryPath = $PSScriptRoot

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error 'GitHub CLI was not found. Install it and run "gh auth login".'
    exit 1
}

gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'GitHub CLI is not authenticated. Run "gh auth login".'
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Branch)) {
    $Branch = git -C $repositoryPath branch --show-current
}

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($Branch)) {
    Write-Error 'Could not determine the source branch.'
    exit 1
}

$remoteBranch = git -C $repositoryPath ls-remote --heads origin "refs/heads/$Branch"
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($remoteBranch)) {
    Write-Error "The branch '$Branch' does not exist on origin. Push it before creating the release."
    exit 1
}

$currentBranch = git -C $repositoryPath branch --show-current
if ($currentBranch -eq $Branch) {
    $changes = git -C $repositoryPath status --short
    if (-not [string]::IsNullOrWhiteSpace(($changes -join ''))) {
        Write-Error 'The current branch has uncommitted changes. Commit and push them before creating the release.'
        exit 1
    }

    git -C $repositoryPath fetch origin $Branch --quiet
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Could not refresh origin/$Branch."
        exit 1
    }

    $localCommit = git -C $repositoryPath rev-parse $Branch
    $remoteCommit = git -C $repositoryPath rev-parse "origin/$Branch"
    if ($localCommit -ne $remoteCommit) {
        Write-Error "The local branch '$Branch' and origin/$Branch do not point to the same commit. Push or update it first."
        exit 1
    }
}

Write-Host "Starting Android release from branch '$Branch' using the version from pubspec.yaml..."
gh workflow run release-android.yml --repo consultit-angola/BiogestClinic.Mobile --ref $Branch

if ($LASTEXITCODE -ne 0) {
    Write-Error 'GitHub did not accept the release workflow request.'
    exit $LASTEXITCODE
}

Write-Host 'Release requested successfully. Follow it with:'
Write-Host 'gh run list --workflow release-android.yml --limit 1'
