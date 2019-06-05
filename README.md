# unhole
Automatically mkdir to extract .tgz, .tar.gz, .tar.xz, .deb, ls files, cd, rename incrementally, and with regex *

This bash script to combine all steps (mkdir, tar, ar x, cd before extract(if .deb) or after extract, which also performs ls -larthiF --context --color, rename/update new destination directory with nice incremental number without accidentally overwritten. Also able to work in regex * looping with multiple different paths while also able to ls.)

This bash script contains section "TEMPLATE_OF_BASH_ALIASES" block which let you modify and copy/paste to ~/.bash_aliases

Support .tar.gz but not .gz , which gunzip extract single file only.

## Demonstration video (Click image to play at YouTube): ##

[![watch in youtube](https://i.ytimg.com/vi/nd5U7gwb5w8/hqdefault.jpg)](https://www.youtube.com/watch?v=nd5U7gwb5w8 "unhole")

