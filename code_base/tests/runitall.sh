#!bash

which="alpha"
isentra="yes"
runas=""
port=""

while getopts 'E:W:R:' opt; do
  case $opt in
    E) isentra=$OPTARG ;;
    W) which=$OPTARG ;;
    R) runas=$OPTARG ;;
    P) port=$OPTARG ;;
    *) echo "Invalid option"; exit 1 ;;
  esac
done

tcount=0
tpass=0
tfail=0
faillist=""

cmdargs="-isEntra $isentra -which $which"
if [ "$runas" != "" ]; then
   cmdargs="$cmdargs -runas $runas"
fi
if [ "$port" != "" ]; then
   cmdargs="$cmdargs -port $port"
fi

while read item; do
   echo "Running:  $item $cmdargs"
   tcount=`expr $tcount + 1`
   pwsh -File ./$item $cmdargs
   zz=$?
   if [ $zz -eq 0 ]; then
      echo "$item:  Test Passed"
      tpass=`expr $tpass + 1`
   else
      echo "$item:  Test Failed"
      tfail=`expr $tfail + 1`
      faillist="$faillist $item"
   fi
   echo "Completed:  $item"
   echo "#################################################"
   echo ""
done < test.lst

echo "Tests Run:    $tcount"
echo "Tests Passed: $tpass"
echo "Tests Failed: $tfail"
if [ "$faillist" != "" ]; then
   for item in $faillist; do
      echo "   $item"
   done
fi
