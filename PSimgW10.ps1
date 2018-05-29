#windows image script
#copyright 2018, Daniel Ytterdal, All rights reserved


#Require DSIM & Must be administrator
##TODO TODO

#Flush variables
$imgPath = ''
$mntPath = ''

#Program menu
function Show-Menu{
    param(
    [string]$Title='IMG maintainer'
        )
    cls
    Write-Host "====$Title===="
   
    Write-Host -nonewline "1: Set image path: "; if ($imgPath) {Write-Host -ForegroundColor Green '   OK:' $imgPath} else {write-host -ForegroundColor Red '   Error: Path not set'}
    Write-Host -nonewline "2: Set mount path: "; if ($mntPath) {write-host -ForegroundColor Green '   OK:' $mntpath} else {write-host -ForegroundColor Red '   Error: Path not set'}
    Write-Host "====================="
    Write-Host "3: Mount image"
    Write-Host "4: Add a Update"
    Write-Host "5: Unmount image"
    Write-host "Q: Quit"
}

#LIFTOFF
do{
    Show-Menu
    $input = Read-Host "Vælg 1-5 eller q for at afslutte"
    switch ($input){

        '1'{
         $imgPath=Read-Host "fuld sti til image location: "
            }

        '2'{
         cls
         $mntPath=Read-Host "fuld sti til mount location: "
            }

        '3'{
         cls
         '3'
         #backup old image
         # copy "C:\Images\Win10_x64\sources\install.wim" C:\Images\install-backup.wim

         #mount image
         # Dism /Mount-Image /ImageFile:"C:\Images\install.wim" /Index:1 /MountDir:"C:\mount\windows" /Optimize
            }

        '4'{
         cls
         '4'
         #Add update
         # Dism /Add-Package /Image:"C:\mount\windows" /PackagePath="windows10.0-kb4016871-x64_27dfce9dbd92670711822de2f5f5ce0151551b7d.msu"  /LogPath=C:\mount\dism.lo

         #lock updates
         # DISM /Cleanup-Image /Image:"C:\mount\windows" /StartComponentCleanup /ResetBase /ScratchDir:C:\Temp
            }

        '5'{
         cls
         '5'
         #Umount image and commit changes
         # Dism /Unmount-Image /MountDir:"C:\mount\windows" /Commit

            }
        'q'{
         return
            }
    default{
         cls 
        "Valg ikke genkendt"}
    }
    pause
}
until ($input -eq 'q')
