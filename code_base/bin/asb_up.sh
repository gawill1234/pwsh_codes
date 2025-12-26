#!bash

which="alpha"

if [ "$1" != "" ]; then
   which=$1
fi

front="curl -v -u swagger-user:DKS6f3BdZbZDWDxP "
back="/esb/api/Vendors/VendorInfo.v21-01?VendorName=General%20Electric 2>&1"

if [ "$which" == "beta" ]; then
   middle="https://vaww.dev.ecms.va.gov"
elif [ "$which" == "charlie" ]; then
   middle="https://vaww.dev.ifams.ecms.va.gov"
elif [ "$which" == "test" ]; then
   middle="https://vaww.test.ecms.va.gov"
elif [ "$which" == "preprod" ]; then
   middle="https://vaww.preprod.ecms.va.gov"
else
   middle="https://vaww.dev.alpha.ecms.va.gov"
fi

full="$front$middle$back"

echo $full
xx=`eval $full`

yy=`echo "$xx" | grep "GENERAL ELECTRIC"`

if [ "$yy" != "" ]; then
   echo "ASB on $which is up"
   exit
fi

echo "$xx"
echo "ASB on $which is NOT up"
exit
