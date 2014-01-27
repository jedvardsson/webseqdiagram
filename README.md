This is a Bash script to generate sequence diagrams using the WebSequenceDiagrams webservice.

# Installation
	
	$ git clone https://github.com/jedvardsson/webseqdiagram.git
	$ cd webseqdiagram
	$ ./INSTALL.sh	

# Usage

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
