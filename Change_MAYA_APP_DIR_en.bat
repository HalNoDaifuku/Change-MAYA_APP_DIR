@echo off
title Change MAYA_APP_DIR

rem Delayed Expansion
setlocal enabledelayedexpansion

rem Launguage
set lang_message_warning=Run this batch file at your own risk!`nAre you sure you want to run it?
set lang_message_warning_title=Warning
set lang_message_select_folder=Trying to change the folder where Maya configuration and other files are stored to the following.`nAre you sure about this?`nPressing "No" will open a window where you can choose a folder.`n`n$env:selected_folder
set lang_message_select_folder_title=
set lang_select_folder_title=Select the folder you want to switch to and press OK.
set lang_message_check_folder_warning=Invalid characters have been detected!`nPlease select a folder that contains only single-byte alphanumeric characters.`nPress Cancel to force close.
set lang_message_check_folder_warning_title=Error
set lang_message_confirm=The following folder was changed.`nCopy from the original folder if necessary.`n`n$env:selected_folder
set lang_message_confirm_title=

rem Default folder
set selected_folder=%USERPROFILE%\Documents\maya

rem Warning message
rem Reference: https://qiita.com/aromatibus/items/c1e7b27a8ba1ed07982b
set ps_message_warning="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_warning%\", '%lang_message_warning_title%', 'YesNo', 'Warning'); exit $result;"
powershell -Command %ps_message_warning%

rem No then exit
if %errorlevel% == 7 (
    exit /b 7
)

rem Select folder message
set ps_message_select_folder="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_select_folder%\", '%lang_message_select_folder_title%', 'YesNo', 'Question'); exit $result;"
powershell -Command %ps_message_select_folder%

rem Yes then check the folder (check_folder)
if %errorlevel% == 6 (
    goto check_folder
)

:select_folder
rem Select folder Window
rem Reference: https://stackoverflow.com/a/15885133
set ps_select_folder="(new-object -COM 'Shell.Application').BrowseForFolder(0,'%lang_select_folder_title%',0,0).self.path"
for /f "usebackq delims=" %%I in (`powershell -Command %ps_select_folder%`) do set "selected_folder=%%I"

:check_folder
rem Check if the selected folder contains any non-alphanumeric characters
rem Reference: https://tabibitojin.com/regular-expression-symbols-alphanumeric/
set ps_check_folder="$result = '%selected_folder%' -match '[^ -~]'; exit $result"
powershell -Command %ps_check_folder%

rem If the folder contains any non-alphanumeric characters, display an error.
if %errorlevel% == 1 (
    set ps_message_check_folder_warning="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"!lang_message_check_folder_warning!\", '!lang_message_check_folder_warning_title!', 'OKCancel', 'Error'); exit $result;"
    powershell -Command !ps_message_check_folder_warning!

    rem If Cancel was pressed, exit.
    if !errorlevel! == 2 (
        exit /b 2

    rem Otherwise, select the folder again.
    ) else (
        goto select_folder
    )
)

rem Change the folder and display confirmation.
setx MAYA_APP_DIR %selected_folder%
set ps_message_confirm="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_confirm%\", '%lang_message_confirm_title%', 'OK', 'Information'); exit $result;"
powershell -Command %ps_message_confirm%
