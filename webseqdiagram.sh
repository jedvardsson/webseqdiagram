#!/bin/bash

PROG=$(basename $0)

showhelp() {
cat <<EOF
Generates a PNG file from the given input_file using WebSequenceDiagram.

Usage: $PROG style input_file

    -d          target dir

	style		the web sequence diagram style parameter (e.g. rose)
	input_file	the sequence diagram input file
EOF
    exit;
}

dir='.'
for i
do
    case $1 in
        -h|--help) showhelp; exit 0;;
        -d) dir=$2; shift 2;;
        -*) echo "Unknown option: $1"; exit 1;;
        *) break;;
    esac
done

if [ $# -ne 2 ]; then
    showhelp;
    exit 1;
fi

GENERATOR_URL="https://www.websequencediagrams.com/index.php"
style=$1
source_file=$2
png_file=$dir/${source_file%.*}.png

result=$(curl -sS -k "$GENERATOR_URL" \
    --data-urlencode "style=$style" \
    --data-urlencode "scale=100" \
    --data-urlencode "paginate=0" \
    --data-urlencode "paper=letter" \
    --data-urlencode "landscape=0" \
    --data-urlencode "format=png" \
    --data-urlencode "apiVersion=1" \
    --data-urlencode "width=830" \
    --data-urlencode "message@$source_file")

if echo $result |grep -Pqv '"errors": \[\]'; then
    echo "There were errors:"
    echo $result
    exit 1
fi

web_file=$(echo $result | grep -o '\?png=[a-zA-Z0-9]*')

if [ -z $web_file ]; then
	echo "Could not generate diagram: $result"
	exit 1
fi

wget --no-check-certificate "$GENERATOR_URL$web_file" -O $png_file
