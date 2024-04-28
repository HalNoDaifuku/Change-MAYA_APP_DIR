@echo off
title Change MAYA_APP_DIR

rem 遅延環境変数
setlocal enabledelayedexpansion

rem 言語
set lang_message_warning=このバッチファイルは自己責任で実行してください！`n本当に実行しますか？
set lang_message_warning_title=注意
set lang_message_select_folder=Mayaの設定ファイルなどを格納するフォルダを以下に変更しようとしています。`n$env:selected_folder`n別のフォルダに変更しますか？`n「はい」を押すとフォルダを選択するウィンドウが開きます。
set lang_message_select_folder_title=
set lang_select_folder_title=フォルダを選択してください。
set lang_message_check_folder_warning=半角英数字記号以外の文字を含むフォルダが検出されました！`n半角英数字記号のみのフォルダを選択してください。`nキャンセルを押すと強制終了します。
set lang_message_check_folder_warning_title=エラー
set lang_message_confirm=以下のフォルダに変更しました。`n$env:selected_folder`n必要に応じて元のフォルダからコピーを行ってください。
set lang_message_confirm_title=

rem デフォルトのフォルダ
set selected_folder=%USERPROFILE%\Documents\maya

rem 自己責任の注意メッセージ
rem 参考: https://qiita.com/aromatibus/items/c1e7b27a8ba1ed07982b
set ps_message_warning="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_warning%\", '%lang_message_warning_title%', 'YesNo', 'Warning'); exit $result;"
powershell -Command %ps_message_warning%

rem Noなら終了
if %errorlevel% == 7 (
    exit /b 7
)

rem フォルダ選択メッセージ
set ps_message_select_folder="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_select_folder%\", '%lang_message_select_folder_title%', 'YesNo', 'Question'); exit $result;"
powershell -Command %ps_message_select_folder%

rem Noならフォルダをチェック(check_folder)
if %errorlevel% == 7 (
    goto check_folder
)

:select_folder
rem フォルダ選択画面
rem 参考: https://stackoverflow.com/a/15885133
set ps_select_folder="(new-object -COM 'Shell.Application').BrowseForFolder(0,'%lang_select_folder_title%',0,0).self.path"
for /f "usebackq delims=" %%I in (`powershell -Command %ps_select_folder%`) do set "selected_folder=%%I"

:check_folder
rem 選択されたフォルダに半角英数字記号以外が含まれているかどうか
rem 参考: https://tabibitojin.com/regular-expression-symbols-alphanumeric/
set ps_check_folder="$result = '%selected_folder%' -match '[^ -~]'; exit $result"
powershell -Command %ps_check_folder%

rem 含まれていたら「選択してください。」
if %errorlevel% == 1 (
    set ps_message_check_folder_warning="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"!lang_message_check_folder_warning!\", '!lang_message_check_folder_warning_title!', 'OKCancel', 'Error'); exit $result;"
    powershell -Command !ps_message_check_folder_warning!

    rem 強制終了したらexit
    if !errorlevel! == 2 (
        exit /b 2

    rem しなかったらもう一度フォルダを選択
    ) else (
        goto select_folder
    )
)

rem フォルダの変更&確認
setx MAYA_APP_DIR %selected_folder%
set ps_message_confirm="Add-Type -AssemblyName System.Windows.Forms; $result = [System.Windows.Forms.MessageBox]::Show(\"%lang_message_confirm%\", '%lang_message_confirm_title%', 'OK', 'Information'); exit $result;"
powershell -Command %ps_message_confirm%
