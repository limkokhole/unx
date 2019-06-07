#!/bin/bash
#usage:
#alias_name [-c|-s|-v] myArchive.tar.gz
#alias_name [-c|-s|-v] myArchive.tgz
#alias_name [-c|-s|-v] myArchive.tar

#README: 
#Extended version from https://unix.stackexchange.com/a/198161/64403
#
#Pass -s or --stay, the default is move to destination directory (last directory if multiple *) after extract, but -s will stay on original/current directory after extracted.
#Pass -c or --clear, to delete source .tar or .deb file. It will not clear if failed to extract.
#Pass -v or --verbose, to list parent directory of destination directory/file on progress.
#
#You can also combine to be -sv, svc, and so on.
#
#Regex *, relative path, full path is all supported !
#
#Even though parse ls is not good practice but normal filename shouldn't has problem, also the ls only use for speed up when many existing destination directory has same name, it still works even though count wrong(just need to loop more).

#Add alias in ~/.bash_aliases (don't forget source ~/.bash_aliases if want to test without restart bash)
#E.g:
<<"TEMPLATE_OF_BASH_ALIASES"
#Need source '.', rf: https://stackoverflow.com/questions/255414/why-doesnt-cd-work-in-a-shell-script
#Change the path below to your script path, this alias also used by function below: 
alias unhole='. /home/xiaobai/note/sh/unhole/unhole.sh' 
TEMPLATE_OF_BASH_ALIASES
#Since need source, then also need return/continue instead of exist in whole script, rf: https://unix.stackexchange.com/questions/460099/how-can-i-skip-the-rest-of-a-script-without-exiting-the-invoking-shell-when-sou

#rf: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash -> https://stackoverflow.com/a/33826763/1074998
#reset first to prevent option looping not reset if source this script:
stay_arg=false
clear_arg=false
verbose_arg=false
f_arg=

argc=$#
argv=("$@")
file_argv=0
for (( j=0; j<argc; j++ )); do
	case ${argv[j]} in
	  -s|--stay) stay_arg=true;;
	  -c|--clear) clear_arg=true;;
	  -v|--verbose) verbose_arg=true;;
	  -sc|-cs) stay_arg=true; clear_arg=true;;
	  -sv|-vs) stay_arg=true; verbose_arg=true;;
	  -vs|-sv) clear_arg=true; verbose_arg=true;;
	  -scv|-svc|-csv|-cvs|-vsc|-vcs) stay_arg=true; clear_arg=true; verbose_arg=true;;
	  *) ((file_argv="$file_argv"+1))
	esac;	
done

shopt -s nocasematch
success_cd_path=
orig_pwd="$PWD" #to make multiple * AND ../relative path works
for (( j=0; j<argc; j++ )); do
	case "${argv[j]}" in
	  -s|--stay) :;;
	  -c|--clear) :;;
	  -v|--verbose) :;;
	  -sc|-cs) :;;
	  -sv|-vs) :;;
	  -vs|-sv) :;;
	  -scv|-svc|-csv|-cvs|-vsc|-vcs) :;;
	  *) f_arg="${argv[j]}"; 

		#empty string, happen if run when no filename, or when call custom function accidentally pass -c (only failed at that one onlyand continue next loop)
		if [[ -z "$f_arg" ]]; then echo -e "\033[31;1mEmpty filename. Abort."; tput sgr0; continue;
		fi

		f_arg="$(readlink -f "$PWD"/"$f_arg" )" #to support relative path arg, expand it to full path first
		
		trim_ext="${f_arg##*.}"
		if [ "$trim_ext" == "deb" ]; then
			fileName="$f_arg" #.deb
		else
			fileName="${f_arg%.*}" #extracted filename
		fi

		if [ ! -e "$f_arg" ]; then echo -e "\033[31;1mProvided filename $f_arg not exists. Abort."; tput sgr0; continue;
		elif [ -d "$f_arg" ]; then 
			if [ "$verbose_arg" == true ]; then
				echo -e "\033[36;1mSkipped directory ($f_arg).";  tput sgr0; 
			fi
			continue;
		fi

		#handle the case of archive.tar.gz
		trailingExtension="${fileName##*.}"
		#if [[ ( "$trailingExtension" == "tar" ) || ( "$trailingExtension" == "deb" ) ]]  
		if [[ ( "$trailingExtension" == "tar" ) ]]  
		then
		    fileName="${fileName%.*}"  #remove trailing tar.
		fi

		if [ ! -e "$fileName" ]; then
			if [[ "$trim_ext" != "gz" ]]; then #.gz is >single file, no need prepare file
				mkdir "$fileName"
			fi
			#echo -e "\033[33;1m$fileName"'/ created, untar...'; tput sgr0;
		else
			w=$(ls -1q | egrep "$fileName"_[0-9]+ | wc -l)
			if [ -e "$fileName"_1 ]; then ((w=w-1)); fi #exclude existing fileName_1 bcoz this is not generated from this script, to prevent if _1 and _2 exists then increment +2 to create _4 which is wrong.
			if [ $w -eq 0 ]; then w=2; else ((w=w+2)); fi #1 is missing and start from 2, so always need increment 2
			while [ -e "$fileName"_"$w" ]; do
				((w=w+1))
			done;
			fileName="$fileName"_"$w"
			if [[ "$trim_ext" != "gz" ]]; then #.gz is >single file, no need prepare file
				mkdir "$fileName"
			fi
			#echo -e "\033[33;1m$fileName"'/ created, untar...'; tput sgr0;
		fi

		#the beuty of rmdir is will only remove empty dir, useful here to avoid harmful rm_r command or noise rm_i

		if [[ "$trim_ext" == "deb" ]]; then #must operate after cd, put in 1st if clause

			if [ "$verbose_arg" == true ]; then
				echo -e "\n\033[34;1m."'/:'; tput sgr0;
				ls -larthiF --context --color "$fileName"'/../' #list parent instead of curr dir to support full path arg
			fi

			cd "$fileName/"
			ar x "$f_arg" #use full path to support relative path arg 

			if [ "$clear_arg" == true ]; then
				rm "$f_arg" #[UPDATE] use full path tosupport relative path arg 
				echo -e "\n\033[33;1m$f_arg deleted."; tput sgr0;
			fi

			echo -e "\n\033[34;1m$fileName"'/:'; tput sgr0;
			ls -larthiF --context --color "$fileName/" #use fileName as full path to support full path arg
			cd "$orig_pwd" && success_cd_path="$fileName" #to prevent failure consider as valid directory then final cd to stay will fail

		else
			#https://stackoverflow.com/a/14138301/1074998 (shopt nocasematch), https://stackoverflow.com/questions/1728683/case-insensitive-comparison-of-strings-in-shell-script#comment17032645_1728814 (must use [[ instead of [)
			if [[ "$trim_ext" == "gz" ]]; then
				gzip -cd "$f_arg" > "$fileName" || { 
					echo -e "\033[31;1mUn-gzip failed. Abort."; tput sgr0;
					rm "$fileName"; #test case: touch dummy file, then try to untar it
					if [ -e "$fileName" ]; then
						echo -e "\033[31;1m$fileName"'/ failed to removed.'; tput sgr0;
					else
						if [ "$verbose_arg" == true ]; then
							echo -e "\033[33;1m$fileName"'/ removed.'; tput sgr0;
						fi
					fi
					continue;
				}
			elif [[ "$trim_ext" == "zip" ]]; then
				unzip "$f_arg" -d "$fileName" >/dev/null || { 
					echo -e "\033[31;1mUnzip failed. Abort."; tput sgr0;
					rmdir "$fileName"; #test case: touch dummy file, then try to untar it
					if [ -e "$fileName" ]; then
						echo -e "\033[31;1m$fileName"'/ failed to removed.'; tput sgr0;
					else
						if [ "$verbose_arg" == true ]; then
							echo -e "\033[33;1m$fileName"'/ removed.'; tput sgr0;
						fi
					fi
					continue;
				}
			else
				tar -xf "$f_arg" --strip-components=0 -C "$fileName" 2>/dev/null || {
					if [ "$verbose_arg" == true ]; then
						echo -e "\033[31;1mUntar $fileName failed. Abort."; tput sgr0;
					fi
					rmdir "$fileName"; #test case: touch dummy file, then try to untar it
					if [ -e "$fileName" ]; then
						echo -e "\033[31;1m$fileName"'/ failed to removed.'; tput sgr0;
					else
						if [ "$verbose_arg" == true ]; then
							echo -e "\033[33;1m$fileName"'/ removed.'; tput sgr0;
						fi
					fi
					continue;
				}
			fi

			touch "$fileName" #by default untar keep timestamp with source file which is strange not able to sort by ls

			if [ "$clear_arg" == true ]; then
				rm "$f_arg"
				echo -e "\n\033[33;1m$f_arg deleted."; tput sgr0;
			fi

			if [ "$verbose_arg" == true ]; then
				if [[ "$trim_ext" == "gz" ]]; then #shouldn't ls .gz with ../ since it's single file
					echo -e "\n\033[34;1m""$(readlink -f ""$(dirname $fileName)"/../")"'/:'; tput sgr0;
					ls -larthiF --context --color "$(dirname $fileName)"/
				else
					echo -e "\n\033[34;1m""$(readlink -f "$fileName/../")"'/:'; tput sgr0;
					ls -larthiF --context --color "$fileName"'/../' #list parent instead of curr dir to support full path arg
				fi
				
			fi

			#deprecated: https://superuser.com/questions/186272/check-if-any-of-the-parameters-to-a-bash-script-match-a-string
		
			if [[ "$trim_ext" == "gz" ]]; then
				echo -e "\n\033[36;1m""$(readlink -f "$fileName")"' [.gz]:'; tput sgr0;
				ls -larthiF --context --color "$fileName"
				cd "$orig_pwd" #shouldn't save cd path if .gz since it's single file
			else
				echo -e "\n\033[34;1m$fileName"'/:'; tput sgr0;	
				ls -larthiF --context --color "$fileName"
				cd "$orig_pwd" && success_cd_path="$fileName"
			fi
		fi
		;;
	esac;
done
if [ "$stay_arg" != true ]; then
	if [ -d "$success_cd_path" ]; then #if .gz single file, no need cd
		cd  "$success_cd_path" #if empty will no effect
	fi
fi
#echo  #konsole has bug which doesn't reset immediately(unlees move backward cursor or Enter on new prompt) on return need extra echo to solve this.
shopt -u nocasematch

