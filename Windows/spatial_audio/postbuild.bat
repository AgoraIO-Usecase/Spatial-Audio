if "%1%" == "x64" (
    copy /Y ..\deps\x86_64\*.dll "%2%"
) else (
    copy /Y ..\deps\x86\*.dll "%2%"
)