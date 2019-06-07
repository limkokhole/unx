# unhole
Automatically mkdir to extract .zip, .gz(single file), .tgz, .tar.gz, .tar.xz, .deb, ls files, cd, remove source file, rename incrementally, and with regex *

This bash script combine all steps (mkdir, unzip/tar/gzip/ar x, cd before extract(if .deb) or after extract, which also performs ls -larthiF --context --color, remove source file if -c, rename/update new destination directory with nice incremental number without worry accidentally overwritten. Also able to work in regex * looping with multiple different paths while also able to ls.)

### Add alias in ~/.bash_aliases (don't forget source ~/.bash_aliases if want to test without restart bash). Modify the script path to yours.
    alias unhole='. /home/xiaobai/note/sh/unhole/unhole.sh' 

### Usage:
    unhole [-c|-s|-v] myArchive.tar.gz
    unhole [-c|-s|-v] myArchive.tgz
    unhole [-c|-s|-v] myArchive.tar

### Options Explanation:
    Pass -s or --stay, the default is move to destination directory (last directory if multiple *) after extract, but -s will stay on original/current directory after extracted.
    Pass -c or --clear, to delete source .tar or .deb file. It will not clear if failed to extract.
    Pass -v or --verbose, to list parent directory of destination directory/file on progress.

### Options example (Basically means every possible combination of -c|-s|-v, ../full path, regex *):
    unhole myArchive.tar
    unhole /home/user/myArchive.tar
    unhole myArchive.tar -scv
    unhole *
    unhole ../*
    unhole ../* -c
    unhole ../* -s
    unhole ../*.xz -s
    unhole ../*.deb -s
    unhole ../*.zip -s
    unhole ../*.gz -s
    unhole *.gz -s
    unhole *.tar.gz -sc
    unhole *.gz -scv

### Demonstration video (Click image to play at YouTube): ##

[![watch in youtube](https://i.ytimg.com/vi/nd5U7gwb5w8/hqdefault.jpg)](https://www.youtube.com/watch?v=nd5U7gwb5w8 "unhole")

