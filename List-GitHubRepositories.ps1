<#
.SYNOPSIS
    Lists all repositories for a GitHub organization.

.DESCRIPTION
    This script retrieves all repositories from a specified GitHub organization using the GitHub REST API.
    It supports pagination and can export the results to a CSV file.

.PARAMETER Organization
    The name of the GitHub organization (for example: microsoft, openai, etc.)

.PARAMETER Token
    A GitHub Personal Access Token (PAT) with at least read:org permission.

.EXAMPLE
    .\List-GitHubRepositories.ps1 -Organization "openai" -Token "ghp_xxx"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [string]$Token
)

# Basic configuration
$Headers = @{
    "Authorization" = "token $Token"
    "User-Agent"    = "PowerShell-GitHubRepoLister"
    "Accept"        = "application/vnd.github+json"
}

$AllRepos = @()
$Page = 1
$PerPage = 100

Write-Host "Retrieving repositories for organization '$Organization'..." -ForegroundColor Cyan

do {
    $Url = "https://api.github.com/orgs/$Organization/repos?per_page=$PerPage&page=$Page"
    $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method Get -ErrorAction Stop

    if ($Response.Count -gt 0) {
        $AllRepos += $Response
        Write-Host "  Page $($Page): $($Response.Count) repositories found."
        $Page++
    }
    else {
        break
    }
}
while ($Response.Count -eq $PerPage)

Write-Host "Total repositories retrieved: $($AllRepos.Count)." -ForegroundColor Green
Write-Host ""

# Display results as a table
$AllRepos | Select-Object name, html_url, private, updated_at | Format-Table -AutoSize

# Optional: export results to a CSV file
$OutputFile = ".\GitHubRepos_$Organization.csv"
$AllRepos | Select-Object name, html_url, private, updated_at | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "`nResults saved to: $OutputFile" -ForegroundColor Yellow
