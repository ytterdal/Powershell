#windows image script
#copyright 2018, Daniel Ytterdal, All rights reserved


#Require Must be administrator
##TODO TODO

#set start variables
$imgPath = 'c:'
$mntPath = 'c:'

$dismPath="c:\windows\system32\dism.exe"

$mntImage
$updateLoc
$addUpate

#Program menu
function Show-Menu{
    param(
    [string]$Title='IMG maintainer'
        )
    cls
    Write-Host "====$Title===="
    if (test-path $dismPath) {write-host -ForegroundColor Green "DISM installed at: $dismPath"} else {write-host -ForegroundColor Red "DISM not insatlled! - Please install DISM"} 
    Write-Host -nonewline "1: Image path: "; if ($imgPath) {Write-Host -ForegroundColor green '   OK:' $imgPath} else {write-host -ForegroundColor Red '   Error: Path not set'}
    Write-Host -nonewline "2: Mount path: "; if ($mntPath) {write-host -ForegroundColor green '   OK:' $mntpath} else {write-host -ForegroundColor Red '   Error: Path not set'}
    Write-Host ""
    if ($imgPath -And  $mntPath){
    Write-Host "3: Mount image"
    Write-Host "4: Add a Update"
    Write-Host "5: Unmount image"
    } else {write-host "Please add valid (1) image path and (2) mount path`n $status"}

    Write-host "Q: Quit"
}

do{
    $status = if ($imgPath -and $mntPath) {"UNLOCKED"} else {"LOCKED"}
    Show-Menu
    $input = Read-Host "Choose 1-5 or press Q to exit"
   
    ######### User input actions #########
    switch ($input){
    ######### Path selection for image and mount point #########
        '1'{
        cls
         Write-Host "Example: C:\Images\win10_x64\sources\install.wim"
         Write-Host ""
         $imgPath=Read-Host "full path to image location, including wim: "
         if (test-path $imgPath){write-host "Path OK"} else {write-host "Path error!"; $imgPath = ''}
            }
        '2'{
         cls
         $mntPath=Read-Host "full path to mount location: "
         if (test-path $mntPath){write-host "Path OK"} else {write-host "Path error!"; $mntPath = ''}
            }
    ######### DISM selection #########
        '3'{
         cls
         #backup old image
         Write-Host "Do you wish to backup your Wim?"
         Write-Host "1: Yes"
         write-host "2: No"
         $backupWim = Read-Host "Please select 1 or 2"
          switch ($backupWim) {
            '1'{
            cls
            Write-Host "Backing up $imgPath to $imgPath.backup"
            Read-Host
            # copy "$imgPath" "$imgPath.backup"
            } 
            '2'{
            Write-Host "...Brave men do cry..."
            Read-Host
            }
            
            default{Write-Host "Select 1 or 2"}
            }
         cls
         write-host "mounting image"
         #mount image
         # Dism /Mount-Image /ImageFile:"$imgPath" /Index:1 /MountDir:"$mntPath" /Optimize
            }
        '4'{
         cls
         
         #Add update
         # Dism /Add-Package /Image:"C:\mount\windows" /PackagePath="windows10.0-kb4016871-x64_27dfce9dbd92670711822de2f5f5ce0151551b7d.msu"  /LogPath=C:\mount\dism.log

         #lock updates
         # DISM /Cleanup-Image /Image:"C:\mount\windows" /StartComponentCleanup /ResetBase /ScratchDir:C:\Temp
            }
        '5'{
         cls
         
         #Umount image and commit changes
         # Dism /Unmount-Image /MountDir:"C:\mount\windows" /Commit

            }
    ######### Quit menu #########
        'q'{
         return
            }
    ######### Choise out of scope #########
    default{
         cls 
        "Choice not recognized"}
    }
    pause
}
until ($input -eq 'q')
