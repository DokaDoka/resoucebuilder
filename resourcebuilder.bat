@REM version 0.1.1
@echo off

title Resource Builder
setlocal enabledelayedexpansion

set resources=%cd%

@REM use if resourcebuilder is not in the resouces folder
@REM set resources="YOUR RESOURCES FOLDER HERE"

@cd %resources%

:navigatemenu
   echo.
   cd

   if %cd%==%resources% (
      set count=1
      set options[1]=build
   ) else (
      set count=2
      set options[1]=return
      set options[2]=build
   )

   call :loop1

   call :echooptions

   call :input :navigatemenu

   if !options[%choose%]!==return (
      cd ..
      call :navigatemenu
   )

   if !options[%choose%]!==build (
      call :buildmenu
   ) else (
      set resourcename=!options[%choose%]!
      cd !options[%choose%]!
      call :navigatemenu
   )
goto :eof

:buildmenu
   echo.
   cd

   if %cd%==%resources% (
      set count=2
      set options[1]=navigate
      set options[2]=build all
   ) else (
      set count=3
      set options[1]=return
      set options[2]=navigate
      set options[3]=build all
   )

   call :loop1

   call :echooptions

   call :input :buildmenu

   if !options[%choose%]!==return (
      cd ..
      call :buildmenu
   )

   if !options[%choose%]!==navigate (
      call :navigatemenu
   )

   if "!options[%choose%]!"=="build all" (
      set count=0

      call :loop1

      set buildcount=!count!
      for /l %%x in (1,1,!buildcount!) do (
         set tobuild[%%x]=!options[%%x]!
      )

      call :managermenu
   ) else (
      set resourcename=!options[%choose%]!
      cd !options[%choose%]!

      set buildcount=0

      call :managermenu
   )
goto :eof

:managermenu
   echo.
   cd

   set count=3
   set options[1]=cancel
   set options[2]=pnpm
   set options[3]=yarn

   call :echooptions

   call :input :managermenu

   if !options[%choose%]!==cancel (
      call :buildmenu
   ) else (
      if /i %buildcount% gtr 0 (
         if exist package.json call :build

         for /l %%x in (1,1,!buildcount!) do (
            set resourcename=!tobuild[%%x]!
            cd !tobuild[%%x]!
            call :buildcycle
         )

         cd ..
      ) else call :buildcycle
   )

   call :buildmenu
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
         call :loop2
      )
      cd ..
   )
goto :eof

:echooptions
   for /l %%x in (1,1,!count!) do (
      echo [%%x] !options[%%x]!
   )
goto :eof

:input
   echo.
   set choose=
   set /p choose=Choose option:

   if not defined choose (
      echo ERROR invalid input
      goto %~1
   )

   if /i %choose% gtr %count% (
      echo ERROR invalid input
      goto %~1
   )

   if not defined options[%choose%] (
      echo ERROR invalid input
      goto %~1
   )
goto :eof

:build
   if !options[%choose%]!==pnpm (
      set command1=!options[%choose%]! i
   ) else (
      set command1=!options[%choose%]!
   )
   set command2=!options[%choose%]! build

   @echo on
   @echo.
   @echo %resourcename%%subfolder%^>%command1%
   @echo.
   @call %command1%
   @echo.
   @echo %resourcename%%subfolder%^>%command2%
   @echo.
   @call %command2%
   @echo off
   copy /y nul ".yarn.installed"
   echo.
goto :eof

:buildcycle
   set subfolder=
   if exist package.json call :build

   for /d %%y in (*) do (
      set subfolder=\%%y
      cd %%y

      if exist package.json (
         call :build
      )
      cd ..
   )

   cd ..
goto :eof
