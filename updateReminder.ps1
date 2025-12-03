[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Set file path for list of installed software to check.
$pth = 'C:\temp\updateList.txt'
#Is the file there already
$tstPth = Test-Path $pth
#Declare empty list array
$list = @()
#If the file exists already (meaning there is probably already existing content)
if ($tstPth) {
    $conv = Get-Content $pth
    #Every 0th/4th entry is software name
    $i = 0
    #Every 1st/5th entry is the site
    $j = 1
    #Every 2nd/6th entry is the version
    $k = 2
    #Every 3rd/7th entry is the update
    $L = 3
    foreach ($ln in $conv) {
        while ($i -lt $conv.Length) {
            #Store the contents of the txt file into a custom object for easy manipulation of data
            $list += [PSCustomObject]@{
                Software = $conv[$i]
                Link = $conv[$j]
                Version = $conv[$k]
                Update = $conv[$L]
            }
            $i += 4
            $j += 4
            $k += 4
            $L += 4
        }
    }
}

function listProcess {

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
                Update = "No"
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
}

function updateChecker {

    #Clear the txt file to prevent multiple entries of one software. The entire software list is stored in memory during function execution, and will be output back to the list
    Clear-Content -Path $pth
    foreach ($soft in $list) {
        $sof = $soft.Software
        $link = $soft.Link
        $vers = $soft.Version
        $upd = $soft.Update

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
                $upd = $newVer
            }

        }

        #Store everything back out to the text file
        "$sof" | Out-File -FilePath $pth -Append
        "$link" | Out-File $pth -Append
        "$vers" | Out-File $pth -Append
        "$upd" | Out-File $pth -Append

        "$list" | Out-File "C:\temp\updateSend.txt"

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

if ($env:USERNAME -match "SYSTEM") {
    updateChecker
    Send-MailMessage -To 'email' -From 'email' -Attachments "C:\temp\updateSend.txt" -Subject "Software version list" -Body "This is the current list of installed software, their versions, and updates if applicable. Please consider updating any outdated software." -SmtpServer 'smtp'
}
else {
    listProcess ; updateChecker
}
