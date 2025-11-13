<#
.SYNOPSIS
    Reads a CSV of GitHub repositories and creates a Git bundle for each.

.PARAMETER CsvFile
    Path to the CSV file containing repositories (must have a column named 'html_url').

.PARAMETER OutputFolder
    Folder where the repositories and bundles will be created.

.EXAMPLE
    .\Create-GitBundles.ps1 -CsvFile ".\GitHubRepos_openai.csv" -OutputFolder "D:\GitBundles"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CsvFile,

    [Parameter(Mandatory = $true)]
    [string]$OutputFolder
)

# Ensure output folder exists
if (-not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory | Out-Null
}

# Import CSV
$Repos = Import-Csv -Path $CsvFile

foreach ($Repo in $Repos) {
    $RepoUrl = $Repo.html_url
    $RepoName = ($RepoUrl -split '/')[-1]  # get last part of URL (repo name)
    $MirrorFolder = Join-Path $OutputFolder ($RepoName + ".git")
    $BundleFile = Join-Path $OutputFolder ($RepoName + ".bundle")

    Write-Host "`nProcessing repository: $RepoName"
    Write-Host "Cloning mirror to: $MirrorFolder"

    # Clone the repository as a mirror
    if (-not (Test-Path $MirrorFolder)) {
        git clone --mirror $RepoUrl $MirrorFolder
    } else {
        Write-Host "Mirror folder already exists, skipping clone."
    }

    # Create bundle
    Write-Host "Creating bundle: $BundleFile"
    Set-Location $MirrorFolder
    git bundle create $BundleFile --all

    # Return to output folder
    Set-Location $OutputFolder
}

Write-Host "`nAll repositories processed."
