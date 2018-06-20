#windows image script
#copyright 2018, Daniel Ytterdal, All rights reserved

#Requires -RunAsAdministrator


#Import module to create backup with processbar.
Import-Module BitsTransfer

#set start variables
$imgPath = ''
$mntPath = ''
$dismPath='C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe'
$dismVersion=(get-childitem $dismPath).VersionInfo.ProductVersion
$mntImage = ''
$updateFile = ''


#Program menu - Lots of text and tests for eyecandy and stability.
function Show-Menu{
    param(
    [string]$Title='WIM maintainer'
        )
    cls
    Write-Host "====$Title===="
    Write-host -nonewline "DISM: "; if (test-path $dismPath) {write-host -nonewline -ForegroundColor Green "DISM OK - "} else {write-host -ForegroundColor Red "DISM not insatlled! - Please install DISM"}; if ($dismVersion -ge '10') {write-host -ForegroundColor Green "Version OK: $dismVersion"} else {write-host -ForegroundColor Red "DISM wrong version! - Please update DISM."; read-host; exit}
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

#Folder browser (thanks to https://stackoverflow.com/a/25690250)
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}


#run program (Main <3 <3 )
do{
    $status = if ($imgPath -and $mntPath) {"UNLOCKED"} else {"LOCKED"}
    Show-Menu
    $input = Read-Host "Choose 1-5 or press Q to exit"
   
    ######### User input actions #########
    switch ($input){
    ######### 1 + 2: Path selection for image and mount point #########
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
         $mntPath=Get-folder
         #$mntPath=Read-Host "full path to mount location: "
         if (test-path $mntPath){write-host "Path OK"} else {write-host "Path error!"; $mntPath = ''}
            }
    ######### 3. DISM selection #########
        '3'{
         cls
         #backup old image
         Write-Host "Do you wish to backup your Wim image?"
         Write-Host "1: Yes"
         write-host "2: No"
         $backupWim = Read-Host "Please select 1 or 2"
          if ($backupWim -eq 1) {
            cls
            Write-Host "Backing up [$imgPath] to --> [$imgPath.bak]"
            Read-Host "Press Enter to start."

            Start-BitsTransfer -Source "$imgPath" -Destination "$imgPath.bak" -Description "Transfering data to WIM Backup" -DisplayName "Creating WIM backup"
            
            } else {
            Write-Host "...Brave men do cry..."
            Read-Host
            }
         cls
         write-host "Mounting image... Please wait"
         #mount image
        &$dismPath /Mount-Image /ImageFile:"$imgPath" /Index:1 /MountDir:"$mntPath" /Optimize
         $mntImage = 1
         #$mntImage = 1; #DEBUG to test variable
            }
    ######### 4. Add Update #########
        '4'{ 
         cls
         #Add update
         $updateFile = Get-FileName
         write-host "Please wait... Applying update..."
         &$dismPath /Add-Package /Image:"$mntPath" /PackagePath="$updateFile" /LogPath="$mntPath\dism.log"
         write-host "Update applied. locking the image update."
         
         #lock updates
         &$dismPath /Cleanup-Image /Image:"$mntPath" /StartComponentCleanup /ResetBase /ScratchDir:C:\Temp
            }
    ######### 5. Unmount #########
        '5'{
         cls
         #Unmount image and commit changes
         write-host "Unmounting image and commiting change - This will take a while."
         &$dismPath /Unmount-Image /MountDir:"$mntPath" /Commit

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
