#! /bin/bash
# -----------------------------------------------------------------------
# A Bash script to check the compiled Java version of a JAR file
# (C) 2019-2023  Sylvain Hallé
# 
# Laboratoire d'informatique formelle
# Université du Québec à Chicoutimi, Canada
# 
# Usage: check-jar.sh jarfile1 [jarfile2 ...]
# -----------------------------------------------------------------------
ONLY_FIRST_FILE=true
MAX_MAJOR=0
WORK_DIR=$(mktemp -d)
#WORK_DIR="/tmp/tmptest"

# Check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# Delete the temp directory
function cleanup {
  rm -rf "$WORK_DIR"
  tput init
  #echo "Deleted temp working directory $WORK_DIR"
}

# Pad a string (for nicer display)
function pad () { [ "$#" -gt 1 ] && [ -n "$2" ] && printf "%$2.${2#-}s" "$1"; }

# Check one class file
function check {
  found=false
  for file in *.class;
  do
  	[ -f "$file" ] || continue
    msg=$(javap -v $file | grep major)
    ver=${msg:17:2}
    if [ "$ver" -gt "$MAX_MAJOR" ]; then
      echo "$file $ver"
      MAX_MAJOR="$ver"
    fi
    found=true
    break
  done
  if [ $ONLY_FIRST_FILE = true ] && [ $found = false ];
  then
    for d in *;
    do
      if [ -d "$d" ]; then
        pushd $d > /dev/null
        pwd=$(pwd)
        classname=${pwd#"$WORK_DIR"/}
        echo -en "\r\e[K$classname/"
        check
        popd > /dev/null
      fi
    done
  fi
}

# Check one JAR file
function process {
	#MAX_MAJOR=0
	filename=$(basename "$1")
	cp $1 $WORK_DIR
	pushd $WORK_DIR > /dev/null
	unzip -n -q "$filename" "*.class" 2> /dev/null
	for file in *.class;
	do
	  [ -f "$file" ] || continue
	  msg=$(javap -v $file | grep major)
	  ver=${msg:17:2}
	  if [ "$ver" -gt "$MAX_MAJOR" ]; then
		echo -en "$file $ver"
		MAX_MAJOR="$ver"
	  fi
	  break
	done
	for d in *;
	do
	  if [ -d "$d" ]; then
		pushd $d > /dev/null
		check
		popd > /dev/null
	  fi
	done
	echo -e "\r\e[K"
	popd > /dev/null
	echo -en "$filename: \e[1m"
	case $MAX_MAJOR in
	  0)
		echo "No class file found"
		;;
	  45)
		echo "Java 1.1"
		;;
	  46)
		echo "Java 1.2"
		;;
	  47)
		echo "Java 1.3"
		;;
	  48)
		echo "Java 1.4"
		;;
	  49)
		echo "Java 1.5"
		;;
	  50)
		echo "Java 6"
		;;
	  51)
		echo "Java 7"
		;;
	  52)
		echo "Java 8"
		;;
	  53)
		echo "Java 9"
		;;
	  54)
		echo "Java 10"
		;;
	  55)
		echo "Java 11"
		;;
	  56)
		echo "Java 12"
		;;
	  57)
		echo "Java 13"
		;;
	  58)
		echo "Java 14"
		;;
	  59)
		echo "Java 15"
		;;
	  60)
		echo "Java 16"
		;;
	  61)
		echo "Java 17"
		;;
	  62)
		echo "Java 18"
		;;
	  63)
		echo "Java 19"
		;;
	  64)
		echo "Java 20"
		;;
	  *)
		echo "Other Java version"
		;;
	esac
	echo -en "\e[22m"
}

# Register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

# Check all JAR files passed as arguments to the script
for file do
	process "$file"
done