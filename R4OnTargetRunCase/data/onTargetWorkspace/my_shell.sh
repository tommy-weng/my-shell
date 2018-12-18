#!/bin/bash
#set -x

log()
{
    timestamp=`date +[%Y-%m-%d,%H:%M:%S]`
    echo "$timestamp $1"
}

check_result()
{
    if [ $? -ne 0 ]; then
        log "*** $1 failed"
        exit 1
    else
        log "*** $1 successful......................................................................."
    fi
}

syncBin()
{
    log "Sync bin......................................................................."
    cd package
    tar -zxf mimo_r4.tar.gz
    cd -
}

getPingStatus()
{
    BTS_STATUS=""
    STATUS=`ping 192.168.255.1 -w 3 | grep -i "TTL="`
    if [ "$STATUS" != "" ]; then
        log "BTS power on"
        BTS_STATUS=true
    else
        log "BTS power off"
        BTS_STATUS=false
    fi
}

getBTSStatus()
{
   result=`grep 'TDDPS/FID_MGMT_STARTUP/LaunchMacProcess=0x123' btslog_start.log`
   if [ "$result" != "" ]; then
          BTS_STATUS="onair"
   else
          BTS_STATUS=""
   fi
}

showTicks()
{
   for ((t=1; t<=$1; t++));do
       printf "%s" "$2" #echo -n $2
       if [ $(($t%60)) == 0 ]; then
           printf "\n"
       fi
       
       getBTSStatus
       if [ "$BTS_STATUS" == "onair" ]; then
           return 1
       fi

       sleep 1
   done
   return 0
}

waitTicks()
{
   for ((t=1; t<=$1; t++));do
       echo -n $2
       if [ $(($t%60)) == 0 ]; then
           printf "\n"
       fi

       sleep 1
   done
   return 0
}

restBTS()
{
    for i in {1..3}; do
        ssh toor4nsn@192.168.255.1 "reboot"
        echo "" > btslog_start.log
        python kill_process.py
        log "reboot bts............................"
        nc -ulp 51000 >> btslog_start.log &
        showTicks "240" "."
        if [ "$?" == "0" ]; then
            log "Reboot bts $i time failed."
        else
            echo
            log "Reboot bts $i time successful."
            break
        fi
    done

    if [ "$BTS_STATUS" != "onair" ];then
        log "dsp is not ready................................................."
        exit 1
    fi
}

flashBts_with_all_cases()
{
    log "Start to flash bts........................................."
    cd package
    ssh toor4nsn@192.168.255.1 'rm -rf *.log' 
    ssh toor4nsn@192.168.255.1 'rm -rf /ffs/run/dsp/PsScheduler'
    ssh toor4nsn@192.168.255.1 'rm -rf /ffs/run/swpool/DSPHWAPI/dsprtsw.*'
    ssh toor4nsn@192.168.255.1 'rm -rf ffs/run/swpool/LTE/TDDMACNODE/addons/*'
    scp -r PsScheduler toor4nsn@192.168.255.1:/ffs/run/dsp/
    scp -r dsprtsw.bin toor4nsn@192.168.255.1:/ffs/run/swpool/DSPHWAPI
    scp -r release/*.txz toor4nsn@192.168.255.1:/ffs/run/swpool/LTE/TDDMACNODE/addons
    ssh toor4nsn@192.168.255.1 'cd /ffs/run/dsp/PsScheduler && chmod +x LteMacClient'
    ssh toor4nsn@192.168.255.1 'cd /ffs/run/swpool/LTE/TDDMACNODE/addons && crasign *.txz'
    ssh toor4nsn@192.168.255.1 'cd /ffs/run/swpool/DSPHWAPI && crasign dsprtsw.bin && ./default-install.sh'
    cd -
}

flashTargetCase()
{
    log "Changing target case........................................"
    if [ -f "PsScheduler/$targetCase" ]; then
        scp -r PsScheduler/$targetCase toor4nsn@192.168.255.1:/ffs/run/dsp/PsScheduler/
    else
        scp -r PsScheduler/CP/$targetCase toor4nsn@192.168.255.1:/ffs/run/dsp/PsScheduler/CP/
    fi
}

flashCase()
{
    cd package
    flashTargetCase
    cd -
}

flashBts()
{
    log "Start to flash bts.........................................."
    cd package
    ssh toor4nsn@192.168.255.1 'rm -rf *.log' 
    ssh toor4nsn@192.168.255.1 'rm -rf /ffs/run/dsp/PsScheduler'
    ssh toor4nsn@192.168.255.1 'rm -rf /ffs/run/swpool/DSPHWAPI/dsprtsw.*'
    ssh toor4nsn@192.168.255.1 'rm -rf ffs/run/swpool/LTE/TDDMACNODE/addons/*'
    ssh toor4nsn@192.168.255.1 'mkdir -p /ffs/run/dsp/PsScheduler/CP'
    scp -r PsScheduler/LteMacClient toor4nsn@192.168.255.1:/ffs/run/dsp/PsScheduler/
    scp -r PsScheduler/MSG toor4nsn@192.168.255.1:/ffs/run/dsp/PsScheduler/
    scp -r PsScheduler/PsCommon toor4nsn@192.168.255.1:/ffs/run/dsp/PsScheduler/
    scp -r PsScheduler/PsPrivate toor4nsn@192.168.255.1:/ffs/run/dsp/PsScheduler/
    flashTargetCase
    scp -r dsprtsw.bin toor4nsn@192.168.255.1:/ffs/run/swpool/DSPHWAPI
    scp -r release/*.txz toor4nsn@192.168.255.1:/ffs/run/swpool/LTE/TDDMACNODE/addons
    ssh toor4nsn@192.168.255.1 'cd /ffs/run/dsp/PsScheduler && chmod +x LteMacClient'
    ssh toor4nsn@192.168.255.1 'cd /ffs/run/swpool/LTE/TDDMACNODE/addons && crasign *.txz'
    ssh toor4nsn@192.168.255.1 'cd /ffs/run/swpool/DSPHWAPI && crasign dsprtsw.bin && ./default-install.sh'
    cd -
}

runCase()
{
    log "Start to run sct case....................................."
    rm -f logs/*.log
    python kill_process.py
    nc -ulp 51000 >> "$targetCase"_bts.log &
    if [ -f "package/PsScheduler/$targetCase" ];then
        log "Run CNP case on target...................................."
        cmd="ssh -q -o PreferredAuthentications=publickey -o IdentityFile=/user/toor4nsn/temp_priv_key -o CheckHostIP=no -o StrictHostKeyChecking=no toor4nsn@192.168.253.20 \"cd /ffs/run/dsp/PsScheduler&&./LteMacClient --startup=nid=0x1443 -c lte.rtm.startup.script=$targetCase\" |tee $targetCase.log 2>&1"
    else
        log "Run CNP case with physim.................................."
        cmd="ssh -q -o PreferredAuthentications=publickey -o IdentityFile=/user/toor4nsn/temp_priv_key -o CheckHostIP=no -o StrictHostKeyChecking=no toor4nsn@192.168.253.20 \"cd /ffs/run/dsp/PsScheduler&&./LteMacClient -c lte.rtm.startup.loglevel=64 -c lte.sct.vm.log.switch=1 -c lte.sct.vm.log.level=1 -c lte.rtm.startup.script=CP/$targetCase\" |tee $targetCase.log 2>&1"
    fi
    ssh toor4nsn@192.168.255.1 "$cmd"
    scp -r toor4nsn@192.168.255.1:$targetCase.log ./
    if [ `grep -E "Execute testcase failed|ERR: Verify not match|ERR: Verify time out" $targetCase.log | wc -l` -ne 0 ]; then
        log "$targetCase Failed."
    else
        log "$targetCase Pass."
    fi

    dat=`date +%Y%m%d%H%M%S`
    python generate_btslog.py "$targetCase"_bts.log r4_on_target_"$dat"_bts.log
    python generate_btslog.py "$targetCase".log r4_on_target_"$dat"_case.log
    rm "$targetCase"_bts.log "$targetCase".log
    
    mv *.log logs/
}
#set +x
