# unx
Automatically mkdir to eXtracts .iso, .zip, .gz(single file), .tgz, .tar.gz, .tar.xz, .deb, .rar, ls files, cd, remove source file, rename incrementally, touch, and with regex *

This bash script combines all steps (mkdir, 7z/unzip/tar/gzip/ar x/unar r, cd before extract(if .deb) or after extract, which also performs ls -larthiF --context --color (sort by time), remove source file if -c, rename/update new destination directory with default basename_ PLUS pretty incremental number without worry accidentally overwritten(similar to how file explorer do). Touch file/directory to easier sort by time later. Also able to work in regex * looping with multiple different paths while also able to ls.)

The name "unx" inspired by UNp, UN-tar, UNzip and eXtracts.

### Add alias in ~/.bash_aliases (don't forget run `source ~/.bash_aliases` if want to test without restart bash). Modify the script path to yours.
    alias unx='. /home/xiaobai/note/sh/unx/unx.sh'

### Requirement:
    sudo apt install p7zip-full unzip tar gzip binutils unar
    #Note: binutils is for installing ar command.

### Usage:
    unx [-c|-s|-v] myArchive.tar.gz
    unx [-c|-s|-v] myArchive.tgz
    unx [-c|-s|-v] myArchive.tar

### Options Explanation:
    Pass -s or --stay, the default is `cd` to destination directory (last directory if multiple *) after extract, but -s will stay on original/current directory after extracted. Note that it doesn't means stay on current directory when on progress since `ar x` requires `cd`, but it means cd back to original directory on complete.
    Pass -c or --clear, to delete source file such as .tar/.zip/.gz/.iso/.deb file. It will not delete if failed to extract, or destination file/directory is empty. Extract .iso will prompt [y/n] if this flag provided.
    Pass -v or --verbose, to list parent directory of destination directory/file on progress. Also included log such as which directory is skipped(e.g. happen if run with regex *) and which file is trying.
    
    Un-rar only has perform basic extract with unar r which has its own syntax of incrementing directory name, --clear and -stay doesn't works on it.

### Options example (Basically means every possible combination of -c|-s|-v, ../full path, regex *):
    unx myArchive.tar
    unx /home/user/myArchive.tar
    unx myArchive.tar -scv
    unx *
    unx ../*
    unx ../* -c
    unx ../* -s
    unx ../*.xz -s
    unx ../*.deb -s
    unx ../*.zip -s
    unx ../*.gz -s
    unx *.gz -s
    unx *.tar.gz -sc
    unx *.gz -scv
    unx *.iso
    unx foo.rar

### Demonstration video (Click image to play at YouTube): ##

[![watch in youtube](https://i.ytimg.com/vi/hnCHUxaRUIk/hqdefault.jpg)](https://www.youtube.com/watch?v=hnCHUxaRUIk "unx")

