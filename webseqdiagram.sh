#!/bin/bash

PROG=$(basename $0)

showhelp() {
cat <<EOF
Generates a PNG file from the given input_file using WebSequenceDiagram.

Usage: $PROG [options] input_file

    -d|--dir            target dir
    -s|--style          diagram style, default "rose".
    -f|--format         output file format, default "png".

	input_file	        the sequence diagram input file
EOF
    exit;
}

dir='.'
style='rose'
format='png'
for i
do
    case $1 in
        -h|--help) showhelp; exit 0;;
        -d|--dir) dir=$2; shift 2;;
        -f|--format) format=$2; shift 2;;
        -s|--style) style=$2; shift 2;;
        -*) echo "Unknown option: $1"; exit 1;;
        *) break;;
    esac
done

if [ $# -ne 1 ]; then
    showhelp;
    exit 1;
fi

GENERATOR_URL="https://www.websequencediagrams.com/index.php"
source_file=$1
dest_file=$dir/${source_file%.*}.$format

result=$(curl -sS -k "$GENERATOR_URL" \
    --data-urlencode "style=$style" \
    --data-urlencode "scale=100" \
    --data-urlencode "paginate=0" \
    --data-urlencode "paper=letter" \
    --data-urlencode "landscape=0" \
    --data-urlencode "format=$format" \
    --data-urlencode "apiVersion=1" \
    --data-urlencode "message@$source_file")

echo $result
if echo $result |grep -Pqv '"errors": \[\]'; then
    echo "There were errors:"
    echo $result
    exit 1
fi

web_file=$(echo $result | grep -o "\?$format=[a-zA-Z0-9]*")

if [ -z $web_file ]; then
	echo "Could find resulting file: $result"
	exit 1
fi

wget --no-check-certificate "$GENERATOR_URL$web_file" -O $dest_file
