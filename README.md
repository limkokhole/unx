# unx
Automatically mkdir to extracts .zip, .gz(single file), .tgz, .tar.gz, .tar.xz, .deb, ls files, cd, remove source file, rename incrementally, touch, and with regex *

This bash script combine all steps (mkdir, unzip/tar/gzip/ar x, cd before extract(if .deb) or after extract, which also performs ls -larthiF --context --color, remove source file if -c, rename/update new destination directory with default basename_ PLUS pretty incremental number without worry accidentally overwritten. Touch file/directory to easier sort by time later. Also able to work in regex * looping with multiple different paths while also able to ls.)

### Add alias in ~/.bash_aliases (don't forget source ~/.bash_aliases if want to test without restart bash). Modify the script path to yours.
    alias unx='. /home/xiaobai/note/sh/unx/unx.sh' 

### Usage:
    unx [-c|-s|-v] myArchive.tar.gz
    unx [-c|-s|-v] myArchive.tgz
    unx [-c|-s|-v] myArchive.tar

### Options Explanation:
    Pass -s or --stay, the default is `cd` to destination directory (last directory if multiple *) after extract, but -s will stay on original/current directory after extracted. Note that it doesn't means stay on current directory when on progress since `ar x` requires `cd`, but it means cd back to original directory on complete.
    Pass -c or --clear, to delete source file such as .tar/.zip/.deb file. It will not clear if failed to extract.
    Pass -v or --verbose, to list parent directory of destination directory/file on progress.

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

### Demonstration video (Click image to play at YouTube): ##

[![watch in youtube](https://i.ytimg.com/vi/hnCHUxaRUIk/hqdefault.jpg)](https://www.youtube.com/watch?v=hnCHUxaRUIk "unx")

