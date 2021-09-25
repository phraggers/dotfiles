@echo off


echo this is the first line>testfile.txt
echo hello>>testfile.txt
echo this is the last line>>testfile.txt

set "OldLine=hello"
set "NewLine=wassup"
set "File=testfile.txt"
call :replaceLineInFile OldLine with NewLine in File
exit


:replaceLineInFile <LineToReplace> with <NewLine> in <FileName>
setlocal enableDelayedExpansion
set "_ltr=!%~1%!"
set "_nl=!%~3%!"
set "_src=!%~5%!"
set "_tgt=TEMP!%~5%!"
(
   for /F "tokens=1* delims=:" %%a in ('findstr /N "^" %_src%') do (
      set "line=%%b"
      if defined line set "line=!line:%_ltr%=%_nl%!"
      echo(!line!
   )
) > %_tgt%
del %_src%
rename %_tgt% %_src%
endlocal
exit /B