#!/bin/bash

PROG=$(basename $0)
GENERATOR_URL="https://www.websequencediagrams.com/index.php"


showhelp() {
cat <<EOF
Generates an image file from the given WebSequenceDiagram input-file.

Usage: $PROG [options] input_file [output_file]

    -d|--dir            target dir of output_file
    -s|--style          diagram style, default "rose".
    -f|--format         output file format, default "png".

	input_file	        the sequence diagram input file

Examples:

    # Generate an SVG file
    webseqdiagram.sh mydiagram.wsd mydiagram.svg

    # Generate a PNG file using napkin style
    webseqdiagram.sh -s napkin mydiagram.wsd
EOF
    exit;
}

def_dir='.'
def_style='rose'
def_format='png'
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

if [ $# -lt 1 ]; then
    echo "Missing input file."
    exit 1;
fi
input_file=$1
shift

dir=${dir:-$def_dir}
style=${style:-$def_style}

if [ $# -lt 1 ]; then
    format=${format:-$def_format}
    output_file=$dir/${input_file%.*}.$format
else
    output_file=$dir/$1
    format=${output_file##*.}   # get extension of file
fi
shift

result=$(curl -sS -k "$GENERATOR_URL" \
    --data-urlencode "style=$style" \
    --data-urlencode "scale=100" \
    --data-urlencode "paginate=0" \
    --data-urlencode "paper=letter" \
    --data-urlencode "landscape=0" \
    --data-urlencode "format=$format" \
    --data-urlencode "apiVersion=1" \
    --data-urlencode "message@$input_file")

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

wget --no-check-certificate "$GENERATOR_URL$web_file" -O $output_file
