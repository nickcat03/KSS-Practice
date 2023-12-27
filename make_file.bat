@echo off

:: Copy "original.sfc" to "patched.sfc"
copy original.sfc patched.sfc

:: Run the command "asar.exe patch.asm patched.sfc"
asar patch.asm patched.sfc

:: Pause to keep the command prompt window open (optional)
:: pause