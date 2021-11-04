# Contains a raw format hosts list to download, and update your current hosts file
#$remoteHostsList = 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts';

$remoteHostsList = [uri]'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'

# A temporary file to manipulate before storing it as a new hosts file
$tempHostsFile = "$(Get-Location)\tempFile.txt"

# How many hosts should be concated into one line
[int] $concatsPerLine = 15

## Download the file from the source
function Download-HostsFile([uri]$source, [string]$localFile){
    Write-Host "Download-HostsFile
from: $source
to: $localFile"
    Invoke-WebRequest -Uri $source -OutFile $localFile
    Write-Host "File downloaded"
}

## Remove-Comments found here (2021.11.04): https://stackoverflow.com/a/32301428
function Remove-Comments([string]$Path){
    Write-Host "Remove-Comments
Path: $Path"
    # Read file, remove comments and blank lines
    $CleanLines = Get-Content $Path
    foreach ($item in $CleanLines){
        # Trim() removes whitespace from both ends of string
        $TrimmedLine = $item.Trim()

        # Check if what's left is either nothing or a comment
        if([string]::IsNullOrEmpty($TrimmedLine) -or $TrimmedLine -match "^#") {
            # if so, return nothing (inside foreach-object "return" acts like "continue")
            return
        }

        # See if non-empty line contains comment
        $CommentIndex = $_.IndexOf("#")

        if($CommentIndex -ge 0) {
            # if so, remove the comment
            $_ = $_.Substring(0, $CommentIndex)
        }

        # return $Line to $CleanLines
        return $Line
    }

    if($Path -and (Test-Path $Path)){
        [System.IO.File]::WriteAllLines($Path, $CleanLines)
    } #else {
        # No OutFile was specified, write lines to pipeline
        #Write-Output $CleanLines
    #}
    Write-Host "Removed comments"
}

## Concat all the blocked entries in the temp file
function Concat-Blocked-Entries ([string] $Path){
    Write-Host "Concat-Blocked-Entries
Path: $Path"
    Write-Host "Get content of file"
    [System.Collections.ArrayList] $File = Get-Content $Path #File array list
     
        
    Write-Host "Create and fill array to concat"
    [System.Collections.ArrayList] $ArrayOfEntries = @()
    foreach($item in $File){
        # Check if what's left starts with "0.0.0.0"
        if($item -match "^0.0.0.0") {
            $ArrayOfEntries.Add($item)
            $item = ''
        }
    }
    Write-Host "Array filled with elements to block"

    Write-Host "Removing remaining blank lines from file"
    $File = foreach($item in $File){
        if([string]::IsNullOrEmpty($item)){
            return $item
        }
    }
    Write-Host "Blank lines removed"

    Write-Host "Created array for concat, removing leading ip-adress"
    foreach ($item in $ArrayOfEntries){
        $item = $item -replace '^0.0.0.0 '
    }
    Write-Host "Removed leading ip-adress"

    Write-Host "Create a counter and concated array, and start concating the array"
    $tempString = ""
    [System.Collections.ArrayList] $ArrayOfConcat = @()
    for ([int] $x=0; $x -lt $ArrayOfEntries.Length; $x++){
        $tempString = $tempString + $ArrayOfEntries[$x]

        if ($x % $concatsPerLine -eq 0){
            $ArrayOfConcat.Add($tempString)
            $tempString = ""
        }
    }
    
    
    
    
    
    $File = $File + $ArrayOfConcat
    if($Path -and (Test-Path $Path)){
    [System.IO.File]::WriteAllLines($Path, $File)
    
    }
}

Download-HostsFile $remoteHostsList $tempHostsFile
Remove-Comments $tempHostsFile
Concat-Blocked-Entries $tempHostsFile