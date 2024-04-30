@echo off
title Set MAYA_APP_DIR

rem �x�����ϐ�
setlocal enabledelayedexpansion

rem �o�[�W����
set version=v0.0.1

rem �f�t�H���g�̃t�H���_
set selected_folder=%USERPROFILE%\Documents\maya

rem ����
set lang_version=���{��
set lang_message_warning=���̃o�b�`�t�@�C���͎��ȐӔC�Ŏ��s���Ă��������I`n�{���Ɏ��s���܂����H
set lang_message_warning_title=����
set lang_message_select_folder=Maya�̐ݒ�t�@�C���Ȃǂ��i�[����t�H���_���ȉ��ɕύX���悤�Ƃ��Ă��܂��B`n��낵���ł����H`n�u�������v�������ƃt�H���_��I������E�B���h�E���J���܂��B`n`n$env:selected_folder
set lang_message_select_folder_title=
set lang_select_folder_title=�ύX��̃t�H���_��I�����A�uOK�v�������Ă��������B
set lang_message_check_folder_warning=�g�p�ł��Ȃ����������o����܂����I`n���p�p�����L���݂̂��܂ރt�H���_��I�����Ă��������B`n�L�����Z���������Ƌ����I�����܂��B
set lang_message_check_folder_warning_title=�G���[
set lang_message_confirm=�ȉ��̃t�H���_�ɕύX���܂����B`n�K�v�ɉ����Č��̃t�H���_����R�s�[���s���Ă��������B`n`n$env:selected_folder
set lang_message_confirm_title=

rem �o�[�W������\��
call :console_log "Set MAYA_APP_DIR (%lang_version%) %version%"
call :console_log

rem ���ȐӔC�̒��Ӄ��b�Z�[�W
rem �Q�l: https://qiita.com/aromatibus/items/c1e7b27a8ba1ed07982b
call :console_log "%lang_message_warning_title% : %lang_message_warning%"
set ps_message_warning="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_warning%\", '%lang_message_warning_title%', 'YesNo', 'Warning'); exit $result;"
powershell -Command %ps_message_warning%

rem No�Ȃ�I��
if %errorlevel% == 7 (
    call :console_log "No"
    exit /b 7
) else (
    call :console_log "Yes"
)

rem �t�H���_�I�����b�Z�[�W
call :console_log "%lang_message_select_folder_title% : %lang_message_select_folder%"
set ps_message_select_folder="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_select_folder%\", '%lang_message_select_folder_title%', 'YesNo', 'Question'); exit $result;"
powershell -Command %ps_message_select_folder%

rem Yes�Ȃ�t�H���_���`�F�b�N(check_folder)
if %errorlevel% == 6 (
    call :console_log "Yes"
    goto check_folder
) else (
    call :console_log "No"
)

:select_folder
rem �t�H���_�I�����
rem �Q�l: https://stackoverflow.com/a/15885133
call :console_log "%lang_select_folder_title% : %lang_select_folder%"
set ps_select_folder="(new-object -COM 'Shell.Application').BrowseForFolder(0,'%lang_select_folder_title%',0,0).self.path"
for /f "usebackq delims=" %%I in (`powershell -Command %ps_select_folder%`) do set "selected_folder=%%I"

:check_folder
rem �I�����ꂽ�t�H���_�ɔ��p�p�����L���ȊO���܂܂�Ă��邩�ǂ���
rem �Q�l: https://tabibitojin.com/regular-expression-symbols-alphanumeric/
set ps_check_folder="$result = '%selected_folder%' -match '[^ -~]'; exit $result"
powershell -Command %ps_check_folder%

rem �܂܂�Ă�����u�I�����Ă��������B�v
if %errorlevel% == 1 (
    call :console_log "%lang_message_check_folder_warning_title% : %lang_message_check_folder_warning%"
    set ps_message_check_folder_warning="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"!lang_message_check_folder_warning!\", '!lang_message_check_folder_warning_title!', 'OKCancel', 'Error'); exit $result;"
    powershell -Command !ps_message_check_folder_warning!

    rem �����I��������exit
    if !errorlevel! == 2 (
        call :console_log "Cancel"
        exit /b 2

    rem ���Ȃ������������x�t�H���_��I��
    ) else (
        call :console_log "OK"
        goto select_folder
    )
)

rem �t�H���_�̕ύX&�m�F
setx MAYA_APP_DIR %selected_folder%
call :console_log "%lang_message_confirm_title% : %lang_message_confirm%"
set ps_message_confirm="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_confirm%\", '%lang_message_confirm_title%', 'OK', 'Information'); exit $result;"
powershell -Command %ps_message_confirm%

:console_log
rem �R���\�[�����O
echo [%date:~0,4%/%date:~5,2%/%date:~8,2% %time:~0,2%:%time:~3,2%:%time:~6,2%] : %1
exit /b
