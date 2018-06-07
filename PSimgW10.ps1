#windows image script
#copyright 2018, Daniel Ytterdal, All rights reserved
Import-Module BitsTransfer

#Require Must be administrator

#set start variables
$imgPath = ''
$mntPath = ''

$dismPath="c:\windows\system32\dism.exe"

$mntImage = ''
$updateLoc
$addUpate

#Program menu
function Show-Menu{
    param(
    [string]$Title='WIM maintainer'
        )
    cls
    Write-Host "====$Title===="
    if (test-path $dismPath) {write-host -ForegroundColor Green "DISM installed at: $dismPath"} else {write-host -ForegroundColor Red "DISM not insatlled! - Please install DISM"} 
    Write-Host -nonewline "1: Image path: "; if ($imgPath) {Write-Host -ForegroundColor green '   OK:' $imgPath} else {write-host -ForegroundColor Red '   Error: Path not set'}
    Write-Host -nonewline "2: Mount path: "; if ($mntPath) {write-host -ForegroundColor green '   OK:' $mntpath} else {write-host -ForegroundColor Red '   Error: Path not set'}
    Write-Host ""
    if ($imgPath -And  $mntPath){
    Write-Host -nonewline "3: Mount image"; if ($mntImage) {write-host -nonewline -ForegroundColor green '    Image Mounted'; if(Test-Path "$imgPath.bak"){Write-Host -ForegroundColor green '   Backup OK'} else{Write-Host -ForegroundColor Red '   Backup not found!'}} else {write-host -ForegroundColor Red '    Error: Image not loaded'} 
    Write-Host "4: Add a Update"
    Write-Host "5: Unmount image"
    } else {write-host "Please add valid (1) image path and (2) mount path for more options"}
    Write-Host "-------"
    Write-host "Q: Quit"
    write-host ""
}

#File browser (thanks to https://stackoverflow.com/a/22513987)
function Get-FileName($initialDirectory)
{   
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
    Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

#Folder browser (thanks to https://stackoverflow.com/a/11412810)
Function Select-FolderDialog
{
    param([string]$Description="Select Folder",[string]$RootFolder="Desktop")

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
     Out-Null     

   $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
        $objForm.Rootfolder = $RootFolder
        $objForm.Description = $Description
        $Show = $objForm.ShowDialog()
        If ($Show -eq "OK")
        {
            Return $objForm.SelectedPath
        }
        Else
        {
            Write-Error "Operation cancelled by user."
        }
    }


#run program (Main <3 <3 )
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
         $imgPath=Get-FileName
         #$imgPath=Read-Host "full path to image location, including wim: "
         if (test-path $imgPath){write-host "Path OK"} else {write-host "Path error!"; $imgPath = ''}
            }
        '2'{
         cls
         $mntPath=Select-FolderDialog
         #$mntPath=Read-Host "full path to mount location: "
         if (test-path $mntPath){write-host "Path OK"} else {write-host "Path error!"; $mntPath = ''}
            }
    ######### DISM selection #########
        '3'{
         cls
         #backup old image
         Write-Host "Do you wish to backup your Wim image?"
         Write-Host "1: Yes"
         write-host "2: No"
         $backupWim = Read-Host "Please select 1 or 2"
          if ($backupWim -eq 1) {
            cls
            Write-Host "Backing up $imgPath to $imgPath.bak"
            Read-Host "Press Enter to start."

            Start-BitsTransfer -Source "$imgPath" -Destination "$imgPath.bak" -Description "WIM Backup" -DisplayName "Creating WIM backup"
            
            } else {
            Write-Host "...Brave men do cry..."
            Read-Host
            }
         cls
         write-host "mounting image"
         #mount image
         #$mntImage=Dism /Mount-Image /ImageFile:"$imgPath" /Index:1 /MountDir:"$mntPath" /Optimize
         $mntImage = 1; #DEBUG

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
#end
