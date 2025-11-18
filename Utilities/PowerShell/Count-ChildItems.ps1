# function Get-CountOfChildItems {
#     [CmdletBinding()]
param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Path = ".",

    [Parameter(Mandatory = $false)]
    [string]$Filter = "*.postman_collection.json"
)

BEGIN {

    # Setup: Initialize collection for all files
    $AllFiles = New-Object System.Collections.ArrayList
    $Excluded = @("Release", "Debug", "TestResults", "bin", "node_modules", "obj", "packages", "wwwroot")
    Write-Verbose "Starting search for files matching '$Filter', excluding directories 'Release' and 'Debug'."

    # Nested recursive function to collect files, skipping excluded directories
    function Get-FilesRecursive {
        param($CurrentPath)

        # Get files at current level
        $currentFiles = Get-ChildItem -Path $CurrentPath -Filter $Filter -File

        foreach ($file in $currentFiles) {
            $null = $AllFiles.Add($file)
        }

        # Get subdirectories, excluding specified ones
        $subDirs = Get-ChildItem -Path $CurrentPath -Directory | Where-Object { $_.Name -notin $Excluded }

        # Recurse into allowed subdirectories
        foreach ($subDir in $subDirs) {
            Get-FilesRecursive -CurrentPath $subDir.FullName
        }
    }
}

PROCESS {
    # Validate and process each input path
    if (-not (Test-Path $Path)) {
        Write-Error "Path '$Path' does not exist."
        return
    }

    Write-Verbose "Searching recursively from '$Path'."

    # Start recursion for this path
    Get-FilesRecursive -CurrentPath $Path
}

END {
    # Output numbered list and summary
    $counter = 1

    $AllFiles | ForEach-Object {
        Write-Output "$counter. $($_.Name)"
        $counter++
    }

    Write-Verbose "Found $($AllFiles.Count) files total."
}
# }