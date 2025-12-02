function updateChecker {

    #Set file path for list of installed software to check.
    $pth = 'C:\temp\updateList.txt'
    #Is the file there already
    $tstPth = Test-Path $pth
    #Declare empty list array
    $list = @()
    #If the file exists already (meaning there is probably already existing content)
    if ($tstPth) {
        $conv = Get-Content $pth
        #Every 0th/3rd entry is software name
        $i = 0
        #Every 1st/4th entry is the site
        $j = 1
        #Every 2nd/5th entry is the version
        $k = 2
        foreach ($ln in $conv) {
            while ($i -lt $conv.Length) {
                #Store the contents of the txt file into a custom object for easy manipulation of data
                $list += [PSCustomObject]@{
                    Software = $conv[$i]
                    Link = $conv[$j]
                    Version = $conv[$k]
                }
                $i += 3
                $j += 3
                $k += 3
            }
        }
    }
    $cont = $false
    do {
        $add = Read-Host -Prompt "Would you like to add new software or modify existing software to the list to check?"

        if ($add -match '[Aa]dd') {
            $name = Read-Host -Prompt "Please enter the name of the new software`n"
            $lnk = Read-Host -Prompt "Please enter the website URL for the software`n"
            $ver = Read-Host -Prompt "What is the current version you are on?`n"

            #Create a new object as per user request
            $list += [PSCustomObject]@{
                Software = $name
                Link = $lnk
                Version = $ver
            }
        }
        elseif ($add -match '[Mm]odify') {
            debugLog "Please select a software to modify" "Cyan"
            #Easy way to view the whole list. Allows the user to select the object without typing
            $sel = $list | out-consolegridview
            $change = Read-Host -Prompt "Do you want to change the Software, Link, or Version?"
            switch ($change) {
                "Software" {
                    string $mod = Read-Host -Prompt "What would you like to change the software to?"
                    $sel.Software = $mod
                }
                "Link" {
                    $mod = Read-Host -Prompt "What would you like to change the Link to?"
                    $sel.Link = $mod
                }
                "Version" {
                    $mod = Read-Host -Prompt "What would you like to change the Version to?"
                    $sel.Version = $mod
                }
            }
            $c = 0
            while ($c -le $list.Length) {
                #If user selection is in the list at given C index
                if ($sel -in $list[$c]) {
                    $list[$c] = $sel
                    break
                }
                else {
                    $c++
                }
            }
        }
        else {
            $list | out-consolegridview
            $ans = Read-Host -Prompt "Does this list look right?"
            if ($ans -match '[Yy][Es]?[Ss]?') {
                $cont = $true
            }
            else {
                debugLog "Please rewrite the list and re-run this program!" "Magenta" ; exit 0
            }
        }

    } while (!$cont)

    #Clear the txt file to prevent multiple entries of one software. The entire software list is stored in memory during function execution, and will be output back to the list
    Clear-Content -Path $pth
    foreach ($soft in $list) {
        $sof = $soft.Software
        $link = $soft.Link
        $vers = $soft.Version

        #Check the website
        $ping = Invoke-WebRequest -Method Get -Uri $soft.Link

        #Scrape the content for the word 'version'
        if ($ping.Content -match '[Vv]ersion[:]? \d{1,}\.?[\d{1,}\.?]*') {
            #Store the matching line into a variable
            $parVer = $Matches[0]
            #If the version line contains a number
            $parVer -match '\d{1,}\.?[\d{1,}\.?]*' | Out-Null

            $newVer = $Matches[0]

            if ($soft.Version -match $newVer) {
                debugLog "It appears that $sof is up to date!" "Green"
            }
            else {
                debugLog "$sof is not up to date. The current versions is: $vers. The latest version is: $newVer. Please update!" "Yellow"
            }

        }

        #Store everything back out to the text file
        "$sof" | Out-File -FilePath $pth -Append
        "$link" | Out-File $pth -Append
        "$vers" | Out-File $pth -Append

    }
}

function debugLog {

    Param (
        [string]$text,
        [string]$color
    )

    #I use red for errors.
    if ($color -eq "Red") {
        $out = (Get-Date -UFormat "%Y-%m-%d %H:%M:%S") + " " + $text
        $out | Out-File C:\temp\debug.txt -Append
        Write-Host $text -ForegroundColor $color
    }
    else {
        Write-Host $text -ForegroundColor $color
    }

}

updateChecker
