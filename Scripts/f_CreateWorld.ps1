
## CREATE WORLD FUNCTIONS ##



function needsUpdate() {
    $this_version = (Get-Content -Path "./config.json" | ConvertFrom-Json).Version

    $resp = Invoke-RestMethod -Method Get -Uri "https://raw.githubusercontent.com/alecjmaly/WorldCreationScript/master/config.json" 
    $current_version = $resp.Version

    If ($this_version -lt $current_version) {
        Write-Host "`nNOTE: There is an update available. Please run the Run_Install_Update.bat if you would like to update." -ForegroundColor Yellow
        Write-Host "NOTE: Current version source code can be found here: https://github.com/alecjmaly/WorldCreationScript`n" -ForegroundColor Yellow
    }
}



function generate() {
    Param( [string]$input_file,
           [string]$root
         )
    $data = Get-Content $input_file 

    $stats = [System.Collections.ArrayList] @()

    foreach ($row in $data) {
        $first, $rest = $row.Split(',') | Where-Object {$_}
        switch ($first){
            'Run' { 
                foreach($sub_function in $rest) {
                    # run for each .csv
                    #write-host calling $sub_function
                    
                    # repeat number of times in ()
                    #$repeat_num = $sub_function.Split('(')[1].Replace(')', '')
                    If ($sub_function.Split('(').Count -eq 2) {
                        $repeat_num = parseNumber -str $sub_function 
                        $file_name = $sub_function.Split('(')[0]
                    } else {
                        $repeat_num = 1
                        $file_name = $sub_function
                    }

                    
                    for ($i = 0; $i -lt $repeat_num; $i++) {
                        # run for .csv
                        $obj = New-Object PSObject -Property @{'stat'="$($file_name) $(If($i -gt 0) { $i + 1 })"; 'Value'= generate -input_file "$($root)\Data\$($file_name)" -root $root }
                        #write-host $obj.Generate = $obj.Value
                        $stats.Add($obj) | out-null
                    }

                }

                break
            }
            default {
                # normal stat
                cls
                Write-Host "Current object being created: $($input_file.Split('(')[0].Split('\')[$input_file.Split('(')[0].Split('\').Count - 1].Replace('.csv', '') )))`n"
                output -arr $stats -num_tabs 0
                Write-Host `nEvaluating - $first
                $obj = New-Object PSObject -Property @{'Stat'=$first; 'Value'= (getValue -arr ($rest | Where-Object {$_}) )}
                #write-host $obj.Stat = $obj.Value
                $stats.Add($obj) | out-null
            }
      

        }
    }
    cls
    #Write-host `nGenerated $input_file.Split('\')[$input_file.Split('\').Length-1].Replace('.csv','')`n`n
    return $stats 
}



function getValue() {
    Param( [Array]$arr ) 

    #write-host "`nevaluating $($stat)"

    # choose random value
    $choice = $arr[(Get-Random -Maximum $arr.Length)] 

    # get number from () at end of string
    $val = parseNumber -str $choice

    # return generated number and field
    If ($val) {
        return ([string]$val + " " + $choice.Split('(')[0].Trim())
    } else {
        return $choice
    }
}


# gets number from () or random number from (3->10), delimiter: ->
function parseNumber() {
    Param( [string]$str )
    
    $str_to_eval = $str.Split('(')

    If ($str_to_eval.Count -eq 1) {
        return ""
    }

    # get params, either 1 or 2 numbers
    $params = $str_to_eval[1].Replace(')', '') -split "->" | Where-Object {$_}
    
    # return number in ()
    If ($params.Count -eq 1) {
        return $params.Trim()
    }
    # get rand value
    $min = $params[0].Trim()
    $max = $params[1].Trim()

    $val = getRand -min $min -max $max


    return $val
}

function getRand() {
    Param( [int]$min,
           [int]$max
         )

        If ($min -notlike "x") { $x = $min }
        If ($max -notlike "y") { $y = $max }

        
        If ($min -like "x") { 
            If (!$y) {
                $x = getMinOrMaxFromUser -msg "Please enter minimum value"
            } else {
                $x = getMinOrMaxFromUser -msg "Please enter minimum value [max = $($y)]" -type Max -val $y 
            }
        }        
        
        If ($max -like "y") { 
            If (!$x) {  
                $y = getMinOrMaxFromUser -msg "Please enter maximum value"
            } else {
                $y = getMinOrMaxFromUser -msg "Please enter maximum value[min = $($x)]" -type Min -val $x
            }
        } 

        $rand_value = Get-Random -Minimum $x -Maximum ($y+1)  # max+1 = inclusive
        return $rand_value
}

# get max/min input from user
function getMinOrMaxFromUser() {
    Param( [ValidateSet('Max','Min')]
           [string]$type,
           [int]$val,
           [parameter(Mandatory=$true)]
           [string]$msg 
    )

    while ($true) {
        # get valid number
        do {
            $user_input = Read-Host $msg
            $user_input = $user_input -as [Int]
            If(!$val -and $user_input) { return $user_input }
            If(!($user_input)) { Write-Warning "Please enter a valid number" }
        } while (!($user_input));

        If($type -eq 'Max') {
            If($val -and $user_input -lt $val){
                return $user_input
            }
            Write-Warning "Please enter a number less than $($val)"
        } elseif ($type -eq 'Min') {
            If($user_input -gt $val){
                return $user_input
            }
            Write-Warning "Please enter a number greater than $($val)"
        }
    }
}


function repeatString() {
    Param ( [string]$str,
            [int]$num
          )

    $output = ""
    for ($i = 0; $i -lt $num; $i++) {
        $output += $str
    }
    return $output
}

function output() {
    Param( $arr,
           [int] $num_tabs )

    foreach ($row in $arr) {
        # if object
        If($row.Stat -like '*.csv*'){
            Write-Host "`n"(repeatString -str "`t" -num $num_tabs)$row.Stat.Split('\')[$row.Stat.Split('\').Length - 1].Replace('.csv', '') 
            output -arr $row.Value -num_tabs ($num_tabs + 1)

        } else {
            Write-Host (repeatString -str "`t" -num $num_tabs)$row.Stat = $row.Value
        }
    }
}



function pause() {
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}








