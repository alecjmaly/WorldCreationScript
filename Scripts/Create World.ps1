# import functions
."$([environment]::CurrentDirectory)\Scripts\f_CreateWorld.ps1"


###### BODY ##########

try {

    $output = generate -input_file ".\master.csv" -root ([environment]::CurrentDirectory)
    cls
    output -arr $output -num_tabs 0
    needsUpdate
    pause

} catch {
    Write-Error $_
    pause
}
