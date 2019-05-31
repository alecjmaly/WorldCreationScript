# set execution policy to allow scripts to be run
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# import functions
."$([environment]::CurrentDirectory)\Scripts\f_CreateWorld.ps1"




## CUSTOM

function runPath($path) {
    try {

        $output = generate -input_file $path -root ([environment]::CurrentDirectory)
        cls
        Write-Host "Generated $($path)`n" 
        output -arr $output -num_tabs 0
        needsUpdate
    } catch {
        Write-Error $_
    } finally {
        pause
    }
}







cls
$root = "$(([environment]::CurrentDirectory))\Data"
$current_path = $root
$item_selected = 0


# 38 up
# 40 down
# 37 left
# 39 right



do {
    write-host "Press arrow keys to navigate. Enter to select and run a .csv"
    Write-Host "Press q to quit"
    Write-Host
    
     
    Write-Host $current_path
    Write-Host

    $items = Get-ChildItem -Path $current_path

    for ($i = 0; $i -lt $items.Count; $i++) {
        If ($i -eq $item_selected) {
            # item is selected
            Write-Host "* $($items[$i].Name)"
        } else {
            # item is not selected
            Write-Host "  $($items[$i].Name)"
        }
    }
    

    # print if needs update
    needsUpdate

    # get user input
    Write-Host "$message" -ForegroundColor Yellow
    $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown").toString().Split(',')[0]
    
    Switch ($x) {
        13 {
            runPath -path $items[$item_selected].FullName
            
        }
        # up arrow
        38 {
            If ($item_selected -gt 0) {
                $item_selected--
            }
        }
        # down arrow
        40 {
            If ($item_selected -lt ($items.Count - 1)) {
                $item_selected++
            }
        }
        # right arrow
        39 {
            If ($items[$item_selected].getType().Name -like "DirectoryInfo") {
                $current_path = $items[$item_selected].FullName
                $item_selected = 0
            } else {
                runPath -path $items[$item_selected].FullName
            }
            
            
        }
        # left arrow
        37 {
            If ($current_path -inotlike "$(([environment]::CurrentDirectory))\Data") {
                $current_path = Split-Path -Path $current_path
                $item_selected = 0
            }
        }
       
    }
    
    cls
    # print pressed key
    #Write-Host $x
} while ($x -ne 81)


