#!/bin/bash

set -ev
PP_JOBS_DIR=commoncriteria.github.io/pp
PP_NAME=$(basename $GITHUB_REPOSITORY)

# Create PDF files
function createPDFs {
    exitStatus=0

    echo ${PP_NAME}
    echo ${PWD}
    echo $(pwd)
    echo $(pwd)/${PP_JOBS_DIR}/${PP_NAME}/${PP_NAME}-release.html
    echo ./${PWD}/${PP_JOBS_DIR}/${PP_NAME}/${PP_NAME}-release.pdf
    
#    xvfb-run --auto-servernum --server-args='-screen 0, 1024x768x16' /usr/bin/wkhtmltopdf --encoding utf-8 --javascript-delay 15000 http://google.com ./google.pdf
    xvfb-run --auto-servernum --server-args='-screen 0, 1024x768x16' /usr/bin/wkhtmltopdf \
            --javascript-delay 15000  \
            file://$(pwd)/${PP_JOBS_DIR}/${PP_NAME}/${PP_NAME}-release.html?expand=on \
            ./${PWD}/${PP_JOBS_DIR}/${PP_NAME}/${PP_NAME}-release.pdf;
#    for aa in $(find ${PP_JOBS_DIR}/${PP_NAME} -mindepth 1 -name '*.html'); do
#	  echo ${aa}
#          # Make the PDF
#    	    xvfb-run --auto-servernum /usr/bin/wkhtmltopdf \
#		--javascript-delay 15000 \
#		file://${aa}?expand=on \
#		./$PP_JOBS_DIR/$PP_NAME/$(basename ${aa%%.html}.pdf);
#          if [ $? -eq 1 ]; then
#              exitStatus=1
#              return $exitStatus
#          fi
#    	    xvfb-run --auto-servernum /usr/bin/wkhtmltopdf \
#		--javascript-delay 15000 --footer-right '[page]' \
#		file://${aa}?expand=on \
#		./$PP_JOBS_DIR/$PP_NAME/$(basename ${aa%%.html}-paged.pdf);
#          if [ $? -eq 1 ]; then
#              exitStatus=2
#              return $exitStatus
#          fi
#    done
    return $exitStatus
}

# Generate PDF Files
createPDFs 
if [ $? -eq 1 ]; then
    echo "Failed to create a PDF file!"
    exit 1
fi
if [ $? -eq 2 ]; then
    echo "Failed to create a paged PDF file!"
    exit 1
fi
