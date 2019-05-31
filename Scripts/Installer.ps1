function pause() {
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}


$root = "."

# delete files - will redownlaod and clean old unused files
Get-ChildItem -Path $root | ForEach-Object { 
    If(!($_.Name -eq "Data" -and (Test-Path -Path "$($root)\Data")) -and !($_.Name -eq "master.csv" -and (Test-Path -Path "$($root)\master.csv"))) {
        do {
            $file_deleted = $true

            try {
                cls
                Write-Host "`n`nDeleting from from $($_.FullName)"
                Remove-Item -Path $_.FullName -Force -Recurse -Confirm:$false -ErrorAction Stop
            } catch {
                If ($_ -like "Cannot remove*") {
                    Write-Warning "Please close all files at and below this path (if a folder) and press ENTER to continue`n"
                    $file_deleted = $false
                    pause
                }  
            }        
        } while(!$file_deleted)
    } 
}

# download package files
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$client = new-object System.Net.WebClient
$client.DownloadFile("https://github.com/alecjmaly/WorldCreationScript/archive/master.zip","$($root)\file.zip")

# unzip
Expand-Archive "$($root)\file.zip" -DestinationPath $root


# Extract and overwrite all files (Only pull Data Directory if it doesn't already exist)
Get-ChildItem -Path .\WorldCreationScript-master | ForEach-Object { 
    If(!($_.Name -eq "Data" -and (Test-Path -Path "$($root)\Data")) -and !($_.Name -eq "master.csv" -and (Test-Path -Path "$($root)\master.csv"))) {
        Write-Host "Moving from $($_.FullName) $($root)\$($_.Name)"
        Move-Item -Path $_.FullName -Destination "$($root)\$($_.Name)" -Force 
    }
}

# cleanup 
Remove-Item -Path "$($root)\file.zip"
Remove-Item -Path "$($root)\WorldCreationScript-master" -Confirm:$false -Recurse -Force

Write-Host "`n`nUpdate Complete."
pause
