#!/bin/bash
if [ ! -d xmlcv -a ! -f xmlcv/myxmlcv.pl -a ! -f xmlcv/mindosoft_cv.xml ];then
  echo "Please run ./initialize.sh first"
  exit 1
fi
NUM=`ls xmlcv/sergios_stamatis_cv* | wc -l`
if [ $NUM -lt 1 ];then
  echo "Please run ./initialize.sh first"
  exit 2
fi
cp xmlcv/sergios_stamatis_cv* ../cv/
cd ../cv/
rm sergios_stamatis_cv*.fo
echo "All OK. Run 'git push' to update the github page"
exit 0
