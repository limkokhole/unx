# unhole
Automatically mkdir to extract .tgz, .tar.gz, .tar.xz, .deb, ls files, cd, remove source file, rename incrementally, and with regex *

This bash script combine all steps (mkdir, tar, ar x, cd before extract(if .deb) or after extract, which also performs ls -larthiF --context --color, remove source file if -c, rename/update new destination directory with nice incremental number without accidentally overwritten. Also able to work in regex * looping with multiple different paths while also able to ls.)

This bash script contains section "TEMPLATE_OF_BASH_ALIASES" block which let you modify and copy/paste to ~/.bash_aliases

Support .tar.gz but not .gz , which gunzip decompress single file only.

## Add alias in ~/.bash_aliases (don't forget source ~/.bash_aliases if want to test without restart bash)
## Modify the script path to yours.
    alias unhole='. /home/xiaobai/note/sh/unhole/unhole.sh' 

## Usage:
    unhole [-c|-s|-v] myArchive.tar.gz
    unhole [-c|-s|-v] myArchive.tgz
    unhole [-c|-s|-v] myArchive.tar

## Demonstration video (Click image to play at YouTube): ##

[![watch in youtube](https://i.ytimg.com/vi/nd5U7gwb5w8/hqdefault.jpg)](https://www.youtube.com/watch?v=nd5U7gwb5w8 "unhole")

