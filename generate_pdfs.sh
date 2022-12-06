#!/bin/bash

set -ev
PP_JOBS_DIR=commoncriteria.github.io/pp
PP_NAME=$(basename $GITHUB_REPOSITORY)

TOPDF=/usr/bin/wkhtmltopdf --enable-local-file-access --javascript-delay 15000 
# Create PDF files
function createPDFs {
    exitStatus=0

    for aa in $(find ${PP_JOBS_DIR}/${PP_NAME} -mindepth 1 -name '*.html'); do
          # Make the PDF
    	xvfb-run --auto-servernum --server-args='-screen 0, 1024x768x16' \
		 ${TOPDF}\
		file://${PWD}/${aa}?expand=on \
		${PWD}/${PP_JOBS_DIR}/${PP_NAME}/$(basename ${aa%%.html}.pdf);
          if [ $? -eq 1 ]; then
              exitStatus=1
              return $exitStatus
          fi
    	  xvfb-run --auto-servernum --server-args='-screen 0, 1024x768x16' \
		 /usr/bin/wkhtmltopdf --javascript-delay 15000  --enable-local-file-access\		   
		 --footer-right '[page]' \
		file://${PWD}/${aa}?expand=on \
		${PWD}/${PP_JOBS_DIR}/${PP_NAME}/$(basename ${aa%%.html}-paged.pdf);
          if [ $? -eq 1 ]; then
              exitStatus=2
              return $exitStatus
          fi
    done
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
