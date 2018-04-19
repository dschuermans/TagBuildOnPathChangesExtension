[CmdletBinding()]
param(
    [Parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Tag,

    [string[]]$PathFilters = @(),
    
    [string]$WorkingDirectory = "",

    [string]$UseVerbose = "false",
    [string]$CreateTagVariable = "false"
)
begin {
    $CurrentVerbosePreference = $VerbosePreference;

    if($VerbosePreference -eq "SilentlyContinue" -And $UseVerbose -eq "true") {
        $VerbosePreference = "continue"
    }

    $CreateVariable = $false;

    if($CreateTagVariable -eq "true") {
        $CreateVariable = $true;
    }
   
    Set-Location $WorkingDirectory


    Write-Host "Tag: $Tag"
    Write-Host "Filters: $PathFilters"
    Write-Host "Create variable: $CreateVariable"
    Write-Host "Working directory: $(Get-Location)"
}
process {
    $isTagged = $false;

    if($PathFilters -eq $null -Or $PathFilters.Length -eq 0) {
        Write-Verbose "No filters specified, tagging build."
        Write-Host "##vso[build.addbuildtag]$Tag"
        $isTagged = $true
    }
    else{
        # Get changes
        $changes=$(git diff head head~ --name-only)
    
        foreach($file in $changes){
        
            if($null -ne ($PathFilters | ? { $file.StartsWith($_) })){
                Write-Verbose "$File matches a filter, tagging build."
                Write-Host "##vso[build.addbuildtag]$Tag"
                $isTagged = $true
                break
            }
            else{
                Write-Verbose "$File - NO MATCH"
            }
        }
    }

    if($CreateVariable -eq $true){
        Write-Verbose "Creating variable with name $Tag and value $isTagged"
        Write-Host "##vso[task.setvariable variable=$Tag]$isTagged"
    }
}
end {
    $VerbosePreference = $CurrentVerbosePreference
}