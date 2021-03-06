#!/bin/bash
set -ev
# This is the transforms commit branch/timestamp that all projects should
# basically be building to. It's hardcoded right here (not optimal), but
# it'll do for now.
IDEAL_TRANSFORMS="T_VER=$(cat ${PWD}/ci-scripts/CurrentTransforms.txt)"
IGNORE_PROJECTS="app-vetting"
PP_DIR=${PWD}
PP_JOBS_DIR=${PWD}/commoncriteria.github.io
CURRENTLY_BUILDING=$(basename $GITHUB_REPOSITORY)
function info(){
    echo $1 >&2
}

function duplicate_index {
    cp $PP_JOBS_DIR/index.html $PP_JOBS_DIR/index.html.bak
}
function delete_backup_index {
    rm $PP_JOBS_DIR/index.html.bak
}

# Obtain path of protection profiles and protection profile names
function findProtectionProfiles {
    PP_WITH_PATH=$(find ${PP_JOBS_DIR}/pp -maxdepth 1 -mindepth 1 -type d -not -path "*/transforms")
    for path in "${PP_WITH_PATH[@]}"; do
        PP_NAMES+=$(echo "${path}"|rev|cut -d '/' -f1|rev|sort)
        info "PP_NAME is $PP_NAME vs ${path##*/}"
#        if [[ "$IGNORE_PROJECTS" == *"$PP_NAME"* ]]; then
#          PP_NAMES+=$PP_NAME
#        fi
    done
}
# Function to create index.html (Page displaying all Protection Profiles)
function createWebsite {

    cd ${PP_JOBS_DIR}
    (
    cat <<EOF
    <!DOCTYPE html>
      <html>
        <head>
          <!--Import Google Icon Font-->
          <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
          <!-- Compiled and minified CSS -->
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css">

          <style type="text/css">
                  body {
                    overflow-x: hidden;
                    overflow-y: scroll;
                  }
                  nav {
                    background-color: rgb(63,81,181);
                    }

                  nav .brand-logo {
                    font-family: "Roboto","Helvetica","Arial",sans-serif;
                      font-size: 20px;
                      letter-spacing: .02em;
                      font-weight: 400;
                      padding-left: 1rem;
                  }

                  nav .button-collapse i {
                    font-size: 1.7rem;
                    padding-left: 1rem;
                  }

                  .collapsible {
                      margin: 1rem 0 1rem 0;
                  }

        		  .collapsible-body {
                      padding: 0;
                  }

                  .collapsible-header {
                      padding: .5rem;
                  }

	        	  .collapsible-header i {
                      vertical-align: middle;
                  }

    	      .pdf-image, .pdf-image:after {
    	        content: url(data:image/png;base64,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);
    	        display: inline-block;
    	        width: 20%;
                    max-width: 32px;
    	        height: auto;
    	      }

    	      .num-pdf-image, .num-pdf-image:after {
    	        content: url(data:image/png;base64,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);
    	        display: inline-block;
    	        width: 20%;
                    max-width: 32px;
    	        height: auto;
    	      }

    	      .html-image, .html-image:after {
    	        content: url(data:image/png;base64,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);
    	        display: inline-block;
    	        width: 20%;
                    max-width: 32px;
    	        height: auto;
    	      }

	      span.pp_title {
		float: left;
                width: 50%;
	      }

	      span.build_status {
		float: right;
                width: 50%;
	      }

	      img.build_status, img.valid_status{
		vertical-align: middle;
                float: right;
	      }
              .uses_current_transforms{
                color: green;
              }
              .uses_current_transforms::after{
                content: "★";
              }


          </style>

          <!--Let browser know website is optimized for mobile-->
          <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
          <title>Common Criteria Protection Profiles</title>
        </head>

        <body>
            <nav>
              <!--Slide Out Navigation-->
              <ul id="slide-out" class="sidenav">
                  <li><a href="https://github.com/commoncriteria" target="_blank">Common Criteria Github</a></li>
                  <li><a href="https://www.niap-ccevs.org/Profile/" target="_blank">NIAP Protection Profiles</a></li>
                  <li><a href="https://github.com/commoncriteria/pp-template/wiki" target="_blank">PP Dev Wiki</a></li>
                  <li><a href="https://commoncriteria.github.io/pp/transforms/CCProtectionProfile.rng.html" target="_blank">PP Schema Docs</a></li>
                  <li><a href="https://commoncriteria.github.io/pp/transforms/CCModule.rng.html" target="_blank">Module Schema Docs</a></li>
                  <li><a href="https://commoncriteria.github.io/pp/transforms/ConfigAnnex.rng.html" target="_blank">ConfigAnnex Schema Docs</a></li>
                  <li><a href="https://commoncriteria.github.io/pp/transforms/TechnicalDecisions.rng.html" target="_blank">Technical Decisions Schema Docs</a></li>
                  <li><a href="https://commoncriteria.github.io/pp/transforms/BoilerplateSummary.html" target="_blank">Boilerplates</a></li>
              </ul>
              <a href="#" data-target="slide-out" class="sidenav-trigger show-on-large"><i class="material-icons">menu</i></a>
              <!--Navigation bar Header-->
              <div class="nav-wrapper">
                <a href="#!" class="brand-logo">Common Criteria Protection Profiles</a>
              </div>
            </nav>

          <!--Main Page Content-->
          <div class="container">
            <ul class="collapsible" data-collapsible="accordion">
EOF
        for aa in ${PP_NAMES[@]}; do
            T_STATUS=""
            T_VER=""
	    BUILD_TIME=""
	    META_FILE=${PP_JOBS_DIR}/pp/$aa/meta-info.txt
            if [ -r "$META_FILE" ]; then

	       T_VER=$(grep '^T_VER=' $META_FILE)
	       BUILD_TIME=$(grep '^BUILD_TIME=' $META_FILE | tail -c +12)
               if [ "$IDEAL_TRANSFORMS" == "$T_VER" ]; then
                 T_STATUS=' uses_current_transforms'
               fi
            fi
            pwd >&2

	    info "Look for $IDEAL_TRANSFORMS"
	    info "$aa: T_VER is $T_VER"
	    info "T_STATUS is $T_STATUS"
            echo "<li>"
            echo -n "  <div class='collapsible-header'><span class='pp_title$T_STATUS'><i class='material-icons'>folder</i>$aa</span>"
            echo -n "<span class='build_status'><img class='valid_status' src='https://github.com/commoncriteria/$aa/workflows/Build/badge.svg'>"
            echo -n "     <img class='build_status' src='https://github.com/commoncriteria/$aa/workflows/Validate/badge.svg'></span>"
            echo "</div>"
            echo "<div class='collapsible-body'>
                    <table class='bordered striped'>
                      <thead>
                        <tr>
                          <th>Document</th>
                          <th>Links</th>
                          <th>Last Modified</th>
                        </tr>
                      </thead>
                      <tbody>"
            HTMLFILES=$(find ${PP_JOBS_DIR}/pp/$aa -mindepth 1 -name '*.html')
            SORTED_HTMLFILES=($(echo "${HTMLFILES[@]}" | sed 's/ /\n/g' | sort))
            for htmlfile in "${SORTED_HTMLFILES[@]}"; do
                # Full path to html and pdf files on jenkins.
                basename="${htmlfile%%.html}"
                pdffile="${basename}.pdf"
                pdfpaged="${basename}-paged.pdf"
                # Paths for index.html that resides on openshift web server.
		        htmlfile_url=$(sed -E "s/.*\/(pp\/$aa\/.*)/\1/g" <<< $htmlfile)
                pdf_url=${htmlfile_url%%html}pdf
    	        pdf_paged_url=${htmlfile_url%%.html}-paged.pdf

                echo "<tr>
                          <td>${basename##*/}</td>
                          <td><a href='$htmlfile_url' class='html-image'><img title='HTML'></img>"

                if [ -r $pdffile ] ; then
    		        echo "<a href='$pdf_url' class='pdf-image'><img title='PDF'></img></a>"
                fi
    		    if [ -r $pdfpaged ]; then
    		        echo "<a href='$pdf_paged_url' class='num-pdf-image'><img title='PDF w/ Page Numbering'></img></a>"
    		    fi
    	        echo "</td><td>"
# TODO: Once all built PPs have meta-info.txt files in commoncriteria.github.com/pp/$aa/ then we can just echo the BUILD_TIME
                if [ "$CURRENTLY_BUILDING" == "$aa" ]; then
                    if [ -r "$META_FILE" ]; then
                        echo "$BUILD_TIME UTC"
                    else
                        stat -c "%.16z" ${htmlfile}
                    fi
                else
                    if [ -r "$META_FILE" ]; then
                        echo "$BUILD_TIME UTC"
                    else
                        PAST_DATE=$(${PP_DIR}/ci-scripts/last_build_date.py $aa)
                        echo "$PAST_DATE UTC"
                    fi
                fi
                echo "</td></tr>"
            done
            echo "      </tbody>
                      </table>
                    </div>
                  </li>"
        done
        echo "</ul>
          </div>


          <!--Import jQuery before materialize.js-->
          <script type="text/javascript" src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
          <!-- Compiled and minified JavaScript -->
          <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script>

          <script type='text/javascript'>
            \$('.collapsible').collapsible();
            \$('.sidenav').sidenav();
          </script>
        </body>
      </html>"
    ) > ${PP_JOBS_DIR}/index.html
}

function findDirectory() {
    it=$1

    #-- Is it called via the PATH
    if which $it  1>/dev/null 2>&1 ; then         # If it's in the path
    	it=$(which $it)                           # Get where it is
    fi
    #-- Check to see if it's a symlink
    if readlink $it >/dev/null; then              # If it's a link
	it=$(readlink $it)	                  # Then resolve it
    fi

    #-- Fix it up
    DIR=${it%/*}		                  # Strip off the end
    if [ "$DIR" == "$it" ]; then                  # If they're equal (no directories)
    	DIR="."			                  # Set the current directory
    fi
    echo $DIR
}

# Find where we are
DIR=$(findDirectory $0)

# cp $DIR/Encapsulator.html $PP_JOBS_DIR || true

# Build Update website
findProtectionProfiles
duplicate_index
createWebsite
delete_backup_index
if [ $? -eq 1 ]; then
    echo "Failed to create updated Protection Profile Website!"
    exit 1
fi

exit 0
