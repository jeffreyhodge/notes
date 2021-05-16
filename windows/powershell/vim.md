# How to get vim working in powershell or cmd

https://www.vim.org/download.php

the windows version runs inside the command window or powershell window

download gvim and install somewhere you can click because it will pop up a window for the install

```
$client.DownloadFile("https://github.com/vim/vim-win32-installer/releases/download/v8.2.2825/gvim_8.2.2825_x86_signed.exe", "C:\tmp\vim.exe")
```

run the install with
Start-Process C:\tmp\vim.exe

open vim by just typing vim

aliasing apparently is an ordeal in windows, have to edit the registry
you can use doskey (doskey vi=vim) also, but it won't work all the way.  Can't use vi from doskey to open a file and save it.  It will open a file, and you still have to save it with :w somefilename and then just :q out.
