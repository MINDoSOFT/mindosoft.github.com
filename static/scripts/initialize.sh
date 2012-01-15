#!/bin/bash

REQUIREDLIB1='libxslt1.1'
REQUIREDLIB2='libxml-libxslt-perl'

# Checking if xmlcv library is present or else download and extract it
if [ ! -d xmlcv ];then
  echo "Directory xmlcv does not exist"
  if [ ! -f xmlcv.tar.gz ];then
    echo "Downloading xmlcv library"
    wget -q http://charlieharvey.org.uk/src/xmlcv.tar.gz
    RETVAL=$?
    if [ $RETVAL -ne 0 ];then
      cp justincase/xmlcv.tar.gz .
      echo "charlieharvey.org.uk is down"
    fi
  fi
  tar xzvf xmlcv.tar.gz
fi

# Checking if required library for xmlcv is installed
dpkg -s ${REQUIREDLIB1} | grep ' installed'
RETVAL=$?
if [ $RETVAL -ne 0 ];then
  echo "Please install ${REQUIREDLIB1} package (then rerun this script) using:"
  echo "sudo apt-get install ${REQUIREDLIB1}"
  exit 1
fi

# Checking if required library for xmlcv is installed
dpkg -s ${REQUIREDLIB2} | grep ' installed'
RETVAL=$?
if [ $RETVAL -ne 0 ];then
  echo "Please install ${REQUIREDLIB2} package (then rerun this script) using:"
  echo "sudo apt-get install ${REQUIREDLIB2}"
  exit 1
fi


# Checking if required files for xmlcv exist 
# mindosoft_cv.xml is my cv file in xml format
# myxmlcv.pl is my custom xmlcv.pl script
if [ ! -f ../cv/mindosoft_cv.xml ];then
  echo "File mindosoft_cv.xml does not exist please reclone the git repository"
  exit 2
fi
if [ ! -f myxmlcv.pl ];then
  echo "File myxmlcv.pl does not exist please reclone the git repository"
  exit 2
fi
echo "Directory xmlcv exists, copying myxmlcv.pl and mindosoft.xml"

# Main work is here, copy the required files then run the myxmlcv.pl script
cp ../cv/mindosoft_cv.xml xmlcv/.
cp myxmlcv.pl xmlcv/.
cd xmlcv
./myxmlcv.pl mindosoft_cv.xml

# Check if the main work finished smoothly
RETVAL=$?
if [ $RETVAL -ne 0 ];then
  echo "A problem occured please rerun this script"
  exit 3
fi
echo "Everything completed successfully. Run ./update_cvs_github_site.sh"
exit 0
