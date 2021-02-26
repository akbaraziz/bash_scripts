xample
if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
  stty -echo;
fi;
# ...
# before point of intended output:
stty +echo && printf -- 'intended output\n';
# silence it again till end of script
stty -echo;
# ...
stty +echo;
exit 0;

###################################################
# Indicate Progress with Animations Example
printf -- 'Performing asynchronous action..';
./trigger-action;
DONE=0;
while [ $DONE -eq 0 ]; do
  ./async-checker;
  if [ "$?" = "0" ]; then DONE=1; fi;
  printf -- '.';
  sleep 1;
done;
printf -- ' DONE!\n';

###################################################
# Color code your output Example
printf -- 'doing something... \n';
printf -- '\033[37m someone else's output \033[0m\n';
printf -- '\033[32m SUCCESS: yay \033[0m\n';
printf -- '\033[33m WARNING: hmm \033[0m\n';
printf -- '\033[31m ERROR: fubar \033[0m\n';
'

###################################################
# Trap forced exit of script Example
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
  echo "** Trapped CTRL-C"
}

for i in `seq 1 5`; do
  sleep 1
  echo -n "."
done

###################################################
