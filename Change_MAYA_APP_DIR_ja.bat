@echo off
title Change MAYA_APP_DIR

rem �x�����ϐ�
setlocal enabledelayedexpansion

rem ����
set lang_message_warning=���̃o�b�`�t�@�C���͎��ȐӔC�Ŏ��s���Ă��������I`n�{���Ɏ��s���܂����H
set lang_message_warning_title=����
set lang_message_select_folder=Maya�̐ݒ�t�@�C���Ȃǂ��i�[����t�H���_���ȉ��ɕύX���悤�Ƃ��Ă��܂��B`n$env:selected_folder`n�ʂ̃t�H���_�ɕύX���܂����H`n�u�͂��v�������ƃt�H���_��I������E�B���h�E���J���܂��B
set lang_message_select_folder_title=
set lang_select_folder_title=�t�H���_��I�����Ă��������B
set lang_message_check_folder_warning=���p�p�����L���ȊO�̕������܂ރt�H���_�����o����܂����I`n���p�p�����L���݂̂̃t�H���_��I�����Ă��������B`n�L�����Z���������Ƌ����I�����܂��B
set lang_message_check_folder_warning_title=�G���[
set lang_message_confirm=�ȉ��̃t�H���_�ɕύX���܂����B`n$env:selected_folder`n�K�v�ɉ����Č��̃t�H���_����R�s�[���s���Ă��������B
set lang_message_confirm_title=

rem �f�t�H���g�̃t�H���_
set selected_folder=%USERPROFILE%\Documents\maya

rem ���ȐӔC�̒��Ӄ��b�Z�[�W
rem �Q�l: https://qiita.com/aromatibus/items/c1e7b27a8ba1ed07982b
set ps_message_warning="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_warning%\", '%lang_message_warning_title%', 'YesNo', 'Warning'); exit $result;"
powershell -Command %ps_message_warning%

rem No�Ȃ�I��
if %errorlevel% == 7 (
    exit /b 7
)

rem �t�H���_�I�����b�Z�[�W
set ps_message_select_folder="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_select_folder%\", '%lang_message_select_folder_title%', 'YesNo', 'Question'); exit $result;"
powershell -Command %ps_message_select_folder%

rem No�Ȃ�t�H���_���`�F�b�N(check_folder)
if %errorlevel% == 7 (
    goto check_folder
)

:select_folder
rem �t�H���_�I�����
rem �Q�l: https://stackoverflow.com/a/15885133
set ps_select_folder="(new-object -COM 'Shell.Application').BrowseForFolder(0,'%lang_select_folder_title%',0,0).self.path"
for /f "usebackq delims=" %%I in (`powershell -Command %ps_select_folder%`) do set "selected_folder=%%I"

:check_folder
rem �I�����ꂽ�t�H���_�ɔ��p�p�����L���ȊO���܂܂�Ă��邩�ǂ���
rem �Q�l: https://tabibitojin.com/regular-expression-symbols-alphanumeric/
set ps_check_folder="$result = '%selected_folder%' -match '[^ -~]'; exit $result"
powershell -Command %ps_check_folder%

rem �܂܂�Ă�����u�I�����Ă��������B�v
if %errorlevel% == 1 (
    set ps_message_check_folder_warning="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"!lang_message_check_folder_warning!\", '!lang_message_check_folder_warning_title!', 'OKCancel', 'Error'); exit $result;"
    powershell -Command !ps_message_check_folder_warning!

    rem �����I��������exit
    if !errorlevel! == 2 (
        exit /b 2

    rem ���Ȃ������������x�t�H���_��I��
    ) else (
        goto select_folder
    )
)

rem �t�H���_�̕ύX&�m�F
setx MAYA_APP_DIR %selected_folder%
set ps_message_confirm="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_confirm%\", '%lang_message_confirm_title%', 'OK', 'Information'); exit $result;"
powershell -Command %ps_message_confirm%
