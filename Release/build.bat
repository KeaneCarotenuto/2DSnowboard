set /p name=Enter Game Name: 
powershell Compress-Archive ..\main.lua, ..\scripts, ..\assets, ..\libraries %name%.zip -Force
ren %name%.zip %name%.love
copy /b D:\Programs\LOVE\love.exe + %name%.love %name%.exe 
powershell Compress-Archive *.dll, *.exe %name%.zip -Force
del %name%.love
pause