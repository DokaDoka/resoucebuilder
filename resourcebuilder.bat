@REM version 0.0.2
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

for /d %%x in (*) do (
   set /A count=!count!+1
   set options[!count!]=%%x
)

echo.
echo %cd%

for /l %%x in (1,1,!count!) do (
   echo [%%x] !options[%%x]!
)

echo.
set choose=
set /p choose=Choose the directory that contains what you want to build:
set userchoice=!options[%choose%]!

if not defined userchoice (
   echo ERROR invalid input
   goto :start
)

set dirpath=%resources%

if /i %choose% gtr 1 set dirpath=%resources%\!options[%choose%]!

:dir

cd %dirpath%

set count=2
set options[1]=Return
set options[2]=Build all

for /d %%x in (*) do (
   set /A count=!count!+1
   set options[!count!]=%%x
)

echo.
echo %cd%

for /l %%x in (1,1,!count!) do (
   echo [%%x] !options[%%x]!
)

echo.
set choose=
set /p choose=Choose option:
set userchoice=!options[%choose%]!

if not defined userchoice (
   echo ERROR invalid input
   goto :dir
)

if /i %choose% equ 1 goto :start

if /i %choose% equ 2 (
   set resource=all
) else (
   set resource=!options[%choose%]!
   cd %resource%
)

:manager

set count=2
set options[1]=pnpm
set options[2]=yarn

echo.
echo %cd%

for /l %%x in (1,1,!count!) do (
   echo [%%x] !options[%%x]!
)

echo.
set choose=
set /p choose=Choose package manager:
set userchoice=!options[%choose%]!

if not defined userchoice (
   echo ERROR invalid input
   goto :manager
)

if %resource% equ all (
   set alltotal=0
   set allresouces=

   for /d %%x in (*) do (
      set /A alltotal=!alltotal!+1
      set allresouces[!alltotal!]=%%x
   )
   set allcount=0
   goto :all
)

set buildfolder=%resource%
cd %resource%

:allcycle

set count=0
set builddirs[1]=web
set builddirs[2]=src
set builddirs[3]=ui
set builddirs[4]=phone
set builddirs[5]=resources

:cycle
if /i %count% equ 5 (
   if %resource% equ all (
      goto :all
   ) else (
      goto :dir
   )
)

set /A count=!count!+1

if exist !builddirs[%count%]!\ (
   cd !builddirs[%count%]!
   if /i %choose% equ 1 (
      goto :pnpm
   ) else (
      goto :yarn
   )
)
goto :cycle

:all
if /i %allcount% equ %alltotal% goto :start

if /i %allcount% gtr 0 cd ..

set /A allcount=!allcount!+1
set buildfolder=!allresouces[%allcount%]!
cd !allresouces[%allcount%]!
goto :allcycle

:pnpm
@echo on
@echo.
@echo %buildfolder%\!builddirs[%count%]!^>pnpm i
@echo.
@call "pnpm" i
@echo.
@echo %buildfolder%\!builddirs[%count%]!^>pnpm build
@echo.
@call "pnpm" build
@echo off
echo.
cd ..
goto :cycle

:yarn
@echo on
@echo.
@echo %buildfolder%\!builddirs[%count%]!^>yarn
@echo.
@call "yarn"
@echo.
@echo %buildfolder%\!builddirs[%count%]!^>yarn build
@echo.
@call "yarn" build
@echo off
echo.
cd ..
goto :cycle
