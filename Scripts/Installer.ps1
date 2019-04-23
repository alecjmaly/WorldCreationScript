# delete files - will redownlaod and clean old unused files
Get-ChildItem -Path "." | ForEach-Object { 
    If(!($_.Name -eq "Data" -and (Test-Path -Path ".\Data")) -and !($_.Name -eq "master.csv" -and (Test-Path -Path ".\master.csv"))) {
        Remove-Item -Path ".\$($_.Name)" -Force -Recurse -Confirm:$false
    } 
}

# download package files
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$client = new-object System.Net.WebClient
$client.DownloadFile("https://github.com/alecjmaly/WorldCreationScript/archive/master.zip",".\file.zip")

# unzip
Expand-Archive .\file.zip -DestinationPath .


# Extract and overwrite all files (Only pull Data Directory if it doesn't already exist)
Get-ChildItem -Path .\WorldCreationScript-master | ForEach-Object { 
        Move-Item -Path $_.FullName -Destination ".\$($_.Name)" -Force 
}

# cleanup 
Remove-Item -Path ".\file.zip"
Remove-Item -Path ".\WorldCreationScript-master" -Confirm:$false -Recurse -Force
