 for i in "${SERVICES[@]}"
  do
    ###CHECK SERVICE####
    `pgrep $i >/dev/null 2>&1`
    STATS=$(echo $?)

    ###IF SERVICE IS NOT RUNNING####
    if [[  $STATS == 1  ]]

        then
        ##TRY TO RESTART THAT SERVICE###
        service $i start

        ##CHECK IF RESTART WORKED###
        `pgrep $i >/dev/null 2>&1`
        RESTART=$(echo $?)

        if [[  $RESTART == 0  ]]
            ##IF SERVICE HAS BEEN RESTARTED###
            then
                ##REMOVE THE TMP FILE IF EXISTS###
                if [ -f "/tmp/$i" ]; 
                then
                    rm /tmp/$i
                fi

            else
                ##IF RESTART DID NOT WORK###

                ##CHECK IF THERE IS NOT A TMP FILE###
                if [ ! -f "/tmp/$i" ]; then

                    ##CREATE A TMP FILE###
                    touch /tmp/$i

                else
                    exit 0;
                fi
        fi
    fi
  done