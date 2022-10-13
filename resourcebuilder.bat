@REM version 0.1.1
@echo off

title Resource Builder
setlocal enabledelayedexpansion

set resources=%cd%

@REM use if resourcebuilder is not in the resouces folder
@REM set resources="YOUR RESOURCES FOLDER HERE"

:start

cd %resources%

set count=1
set options[1]=Current directory

call :loop1

echo.
cd

call :echooptions

echo.
set choose=
set /p choose=Choose the directory that contains what you want to build:

call :validation :start

set dirpath=%resources%

if /i %choose% gtr 1 set dirpath=%resources%\!options[%choose%]!

:dir

cd %dirpath%

set count=2
set options[1]=Return
set options[2]=Build all

call :loop1

echo.
cd

call :echooptions

echo.
set choose=
set /p choose=Choose option:

call :validation :dir

if /i %choose% equ 1 goto :start

if /i %choose% equ 2 (
   set resource=all
   set buildcount=!count!
   for /l %%x in (1,1,!count!) do (
      set tobuild[%%x]=!options[%%x]!
   )
) else (
   set resource=!options[%choose%]!
   set resourcename=!options[%choose%]!
   cd !options[%choose%]!
)

:manager

set count=2
set options[1]=pnpm
set options[2]=yarn

echo.
cd

call :echooptions

echo.
set choose=
set /p choose=Choose package manager:

call :validation :manager

if %resource% equ all (
   for /l %%x in (3,1,!buildcount!) do (
      set resourcename=!tobuild[%%x]!
      cd !tobuild[%%x]!
      call :buildcycle
      cd ..
   )
   goto :start
)

call :buildcycle
goto :dir

:buildcycle
   set subfolder=
   if exist package.json (
      if /i %choose% equ 1 (
         call :pnpm
      ) else (
         call :yarn
      )
   )

   for /d %%y in (*) do (
      set subfolder=\%%y
      cd %%y
      if exist package.json (
         if /i %choose% equ 1 (
            call :pnpm
         ) else (
            call :yarn
         )
      )
      cd ..
   )
goto :eof

:pnpm
   @echo on
   @echo.
   @echo %resourcename%%subfolder%^>pnpm i
   @echo.
   @call "pnpm" i
   @echo.
   @echo %resourcename%%subfolder%^>pnpm build
   @echo.
   @call "pnpm" build
   @echo off
   copy /y nul ".yarn.installed"
   echo.
goto :eof

:yarn
   @echo on
   @echo.
   @echo %resourcename%%subfolder%^>yarn
   @echo.
   @call "yarn"
   @echo.
   @echo %resourcename%%subfolder%^>yarn build
   @echo.
   @call "yarn" build
   @echo off
   copy /y nul ".yarn.installed"
   echo.
goto :eof

:loop1
   for /d %%x in (*) do (
      cd %%x
      if exist package.json (
         set /a count=!count!+1
         set options[!count!]=%%x
      ) else (
         call :loop2
      )
      cd ..
   )
goto :eof

:loop2
   for /d %%y in (*) do (
      cd %%y
      if exist package.json (
         set /a count=!count!+1
         set options[!count!]=%%x
         cd ..
         goto :eof
      ) else (
         call :loop3
      )
      cd ..
   )
goto :eof

:loop3
   for /d %%z in (*) do (
      cd %%z
      if exist package.json (
         set /a count=!count!+1
         set options[!count!]=%%x
         cd ..
         goto :eof
      )
      cd ..
   )
goto :eof

:echooptions
   for /l %%x in (1,1,!count!) do (
      echo [%%x] !options[%%x]!
   )
goto :eof

:validation
   if /i %choose% gtr %count% (
      echo ERROR invalid input
      goto %~1
   )
   if not defined options[%choose%] (
      echo ERROR invalid input
      goto %~1
   )
goto :eof
