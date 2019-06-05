#!/bin/bash
#usage:
#alias_name [-c|-s] myArchive.tar.gz
#alias_name [-c|-s] myArchive.gz
#alias_name [-c|-s] myArchive.tar

#hole: 
#Extended version from https://unix.stackexchange.com/a/198161/64403
#Pass -s or --stay, to stay on current dir without `cd`
#Pass -c or --clear, to delete source .tar or .deb file. It will not clear if failed to extract.
#Not support for regex such as *.tar.xz, which only working on right-most single file at one time.
#Even though parse ls is not good practice but normal filename shouldn't has problem, also the ls only use for speed up when many existing destination directory has same name, it still works even though count wrong(just need to loop more).

#Add alias and custom function in ~/.bash_aliases (don't forget source ~/.bash_aliases if want to test without restart bash)
#Need source, rf: https://stackoverflow.com/questions/255414/why-doesnt-cd-work-in-a-shell-script 
#Since need source, then also need return instead of exist in whole script, rf: https://unix.stackexchange.com/questions/460099/how-can-i-skip-the-rest-of-a-script-without-exiting-the-invoking-shell-when-sou
#E.g:
<<"TEMPLATE_OF_BASH_ALIASES"
#https://stackoverflow.com/questions/255414/why-doesnt-cd-work-in-a-shell-script
#Change the path below to your script path, this alias also used by function below: 
alias unhole='. /home/xiaobai/note/sh/unhole.sh'
#e.g. unhole_all ../*.deb , which loop regex *.deb path, and will NOT DELETE original .deb
#always -s because of contradiction if want to stay on current directory but still cd to other path of regex *.
function unhole_all() { 
	orig_pwd="$PWD" #to make multiple * AND ../relative path works
	for f in "$@"; do unhole "$f" -s; cd "$orig_pwd"; done;
}
#unhole_all_c ../*.deb , which loop regex *.deb path, and will DELETE (-c a.k.a. clear) original .deb
function unhole_all_c() {
	orig_pwd="$PWD" 
	for f in "$@"; do unhole "$f" -sc; cd "$orig_pwd"; done;
}
TEMPLATE_OF_BASH_ALIASES

#rf: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash -> https://stackoverflow.com/a/33826763/1074998
#reset first to prevent option looping not reset if source this script:
stay_arg=false
clear_arg=false
f_arg=
while [[ "$#" -gt 0 ]]; do case $1 in
  -s|--stay) stay_arg=true;;
  -c|--clear) clear_arg=true;;
  -sc|-cs|--sc|--cs) stay_arg=true; clear_arg=true;;
  *) f_arg="$1";;
esac; shift; done

#empty string, happen if run when no filename, or when call custom function accidentally pass -c (only failed at that one onlyand continue next loop)
if [[ -z "$f_arg" ]]; then echo -e "\033[31;1mEmpty filename. Abort."; tput sgr0; echo; return;
fi
f_arg="$(readlink -f "$f_arg")" #to support relative path arg, expand it to full path first

#if [ "$stay_arg" = true ]; then echo "Should stay, $stay_arg"; else echo 'dont stay'; fi
#if [ "$clear_arg" = true ]; then echo "Should clear, $clear_arg"; else echo 'dont clear'; fi
#echo 'f_arg: '"$f_arg"

trim_ext="${f_arg##*.}"
if [ "$trim_ext" == "deb" ]; then
	fileName="$f_arg" #.deb
else
	fileName="${f_arg%.*}" #extracted filename
fi
#konsole need extra `echo` to reset color immediately before `return`.
if [ ! -e "$f_arg" ]; then echo -e "\033[31;1mProvided filename $fileName not exists. Abort."; tput sgr0; echo; return;
elif [ -d "$f_arg" ]; then echo -e "\033[31;1mUntar from directory is not make sense. Abort.";  tput sgr0; echo; return;
fi
#handle the case of archive.tar.gz
trailingExtension="${fileName##*.}"
if [[ ( "$trailingExtension" == "tar" ) || ( "$trailingExtension" == "deb" ) ]]  
then
    fileName="${fileName%.*}"  #remove trailing tar.
fi
if [ ! -e "$fileName" ]; then
	mkdir "$fileName"
	echo -e "\033[33;1m$fileName"'/ created, untar...'; tput sgr0;
else
	w=$(ls -1q | egrep "$fileName"_[0-9]+ | wc -l)
	if [ -e "$fileName"_1 ]; then ((w=w-1)); fi #exclude existing fileName_1 bcoz this is not generated from this script, to prevent if _1 and _2 exists then increment +2 to create _4 which is wrong.
	if [ $w -eq 0 ]; then w=2; else ((w=w+2)); fi #1 is missing and start from 2, so always need increment 2 
	while [ -e "$fileName"_"$w" ]; do
		((w=w+1))
	done;
	fileName="$fileName"_"$w"
	mkdir "$fileName"
	echo -e "\033[33;1m$fileName"'/ created, untar...'; tput sgr0;
fi

#the beuty of rmdir is will only remove empty dir, useful here to avoid harmful rm_r command or noise rm_i

if [ "$trim_ext" != "deb" ]; then
	tar -xf "$f_arg" --strip-components=0 -C "$fileName" || { 
		echo -e "\033[31;1mUntar failed. Abort."; tput sgr0;
		rmdir "$fileName"; #test case: touch dummy file, then try to untar it
		if [ -e "$fileName" ]; then
			echo -e "\033[31;1m$fileName"'/ failed to removed.'; tput sgr0;
		else
			echo -e "\033[33;1m$fileName"'/ removed.'; tput sgr0;
		fi
		echo #konsole has bug which doesn't reset immediately(unlees move backward cursor or Enter on new prompt) on return
		#... need extra echo to solve this.
		return;
	}
	touch "$fileName" #by default untar keep timestamp with source file which is strange not able to sort by ls

	if [ "$clear_arg" == true ]; then
		rm "$f_arg"
		echo -e "\n\033[33;1m$f_arg deleted."; tput sgr0;
	fi

	echo -e "\n\033[34;1m."'/:'; tput sgr0;
	ls -larthiF --context --color

	#deprecated: https://superuser.com/questions/186272/check-if-any-of-the-parameters-to-a-bash-script-match-a-string
	if [ "$stay_arg" == true ]; then 
		echo -e "\n\033[34;1m$fileName"'/:'; tput sgr0;
		ls -larthiF --context --color "$fileName"
	else
		echo 
		echo -e "\033[33;1mcd to $fileName"'/ ->'; tput sgr0;
		cd "$fileName"
		echo -e "\n\033[34;1m./:"; tput sgr0;
		ls -larthiF --context --color
	fi

else
	#mv "./$f_arg" "./$fileName/" #no nid move, juz use ../ when ar x, rf: https://stackoverflow.com/questions/39109435/how-to-ar-x-filename-a-to-different-directory
	echo -e "\n\033[34;1m."'/:'; tput sgr0;
	ls -larthiF --context --color
	echo	
	echo -e "\033[33;1mcd to $fileName"'/ ->'; tput sgr0;
	cd "$fileName/"
	ar x "$f_arg" #[UPDATE] use full path tosupport relative path arg 

	if [ "$clear_arg" == true ]; then
		rm "$f_arg" #[UPDATE] use full path tosupport relative path arg 
		echo -e "\n\033[33;1m$f_arg deleted."; tput sgr0;
	fi

	echo -e "\n\033[34;1m$fileName"'/:'; tput sgr0;
	ls -larthiF --context --color

	if [ "$stay_arg" == true ]; then
		cd "../"
		echo -e "\033[33;1m\n<- back from $fileName"'/'; tput sgr0; echo;
	fi
fi

