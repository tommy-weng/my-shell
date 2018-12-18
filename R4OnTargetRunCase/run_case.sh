#!/bin/bash

targetCase=TC_20M_Conf-1_DL_LTE2666_mMIMO_TM3.rtm
#CP_20M_Conf-2_400_8TTI_TM8_1DRB_QCI7_MassiveMimo.rtm

logs_dir="T_Tools/R4OnTargetRunCase/logs"

check_env()
{
    if [ ! -f data/config.dat ]; then
        echo "Please configure the env."
        echo "Usage: ./config_evn.sh <user> <IP>"
        exit
    fi

    user=`awk '{print $1}' data/config.dat`
    ip=`awk '{print $2}' data/config.dat`
    host_name=$user"@"$ip
    ssh $host_name 'ls onTargetWorkspace > /dev/null 2>&1'
    if [ $? -ne 0 ]; then
        echo "The configuration is not correct, please reconfigure."
        echo "Usage: ./config_evn.sh <user> <IP address>"
        exit
    fi

    cd ../../
}

compile()
{
    rm -rf lteDo
    make update
    is_cnp=`echo $targetCase | grep "CP_"`
    if [ "" == "$is_cnp" ]; then
        make massiveMimo_on_target 2>&1 | tee $logs_dir/compile.log
    else
        make massiveMimo_cnp 2>&1 | tee $logs_dir/compile.log
    fi

    if [ `grep -E " Error | error:"  $logs_dir/compile.log | wc -l` != 0 ]; then
        echo "Compile failed with some errors."
        exit
    fi
}

check_param()
{
    if [ "$1" != "" ]; then
        targetCase="$1"
        cd C_Test/SC_MAC/MacLinuxRtm
        if [ ! -f "PsScheduler/$targetCase" ]; then
            if [ ! -f "PsScheduler/CP/$targetCase" ]; then
                echo "The sct case not exist, please use correct sct case!"
                exit 1
            fi
        fi
        cd -
    fi
}

tar_package()
{
    cd C_Test/SC_MAC/MacLinuxRtm
    cp -f ../../../lteDo/DL_DSP/Config/dspkep_wmp/release/L-N1-MAC_RTM_DL_DSP_00099999.BIN ./dsprtsw.bin
    cp -f ../../../lteDo/exec/arm_cortexa15_nrt/debug/LteMacClient ./PsScheduler/
    cp -rf ../../../lteDo/txz/arm_cortexa15_rt/release ./
    tar -zcf mimo_r4.tar.gz dsprtsw.bin PsScheduler release --exclude *.so --exclude *.in --exclude *_.txz --exclude *.debug
    rm -rf dsprtsw.bin release
    cd -
}

send_package()
{
    cd C_Test/SC_MAC/MacLinuxRtm
    ssh $host_name 'rm -rf ~/onTargetWorkspace/package/*'
    scp mimo_r4.tar.gz $host_name:~/onTargetWorkspace/package/
    rm mimo_r4.tar.gz
    cd -
}

send_case_name()
{
    if [ "" != "$1" ]; then
        echo $targetCase > case.txt
        scp case.txt $host_name:~/onTargetWorkspace/package/
        rm case.txt
    fi
}

send_target_case()
{
    cd C_Test/SC_MAC/MacLinuxRtm/PsScheduler
    
    if [ -f "$targetCase" ]; then
        scp $targetCase $host_name:~/onTargetWorkspace/package/PsScheduler/
    else
        scp CP/$targetCase $host_name:~/onTargetWorkspace/package/PsScheduler/CP/
    fi
    
    cd -
}

copy_log()
{
    echo Log path: `pwd`/$logs_dir/
    scp $host_name:~/onTargetWorkspace/logs/*.log $logs_dir
}

show_help()
{
    echo "##################################################################################"
    echo "################################### Help manual ##################################"
    echo "  Example: ./run_case.sh -m xxx.rtm"
    echo "  Options:"
    echo "    -m      Compile package, Copy package, Reboot bts, Run case"
    echo "    -n      Copy package, Reboot bts, Run case"
    echo "    -d      Copy package, Reboot bts"
    echo "    -r      Reboot bts, Run case"
    echo "    -c      Run case"
    echo "    -h      Show help manual"
    echo "##################################################################################"
    echo "##################################################################################"
}

show_prompt()
{
    echo "Example: \"./run_case.sh -m xxx.rtm\""
    echo "Use \"./run_case.sh -h\" for more informations"
}

run_case()
{
    case "$1" in
        "-r")
            ssh $host_name 'cd ~/onTargetWorkspace; bash main.sh r'
            ;;
        "-c")
            ssh $host_name 'cd ~/onTargetWorkspace; bash main.sh c'
            ;;
        "-d")
            ssh $host_name 'cd ~/onTargetWorkspace; bash main.sh d'
            ;;
        *)
            ssh $host_name 'cd ~/onTargetWorkspace; bash main.sh'
            ;;
    esac
}

query_access()
{
    waitTime=0
    while :; do
        cmd=`ssh $host_name 'ps -ef| grep -E "nc -ulp 51000" | grep -v "grep" | wc -l'`
        if [ $cmd -eq 0 ]; then
            break
        fi
        sleep 1
        ((waitTime++))
        echo "Waiting for someone to finish running case for $waitTime seconds."
    done
    trap "echo Script excuting was interrupted; ssh $host_name 'cd ~/onTargetWorkspace; python kill_process.py';exit" SIGINT SIGTERM SIGHUP
    ssh $host_name 'cd ~/onTargetWorkspace; nc -ulp 51000 >> btslog_start.log &'
}

finish_access()
{
    ssh $host_name 'cd ~/onTargetWorkspace; python kill_process.py'
}

case "$1" in
    "-m")
        check_env
        check_param "$2"
        compile
        tar_package
        query_access
        send_package
        send_case_name "$targetCase"
        run_case
        copy_log
        finish_access
        ;;
    "-n")
        check_env
        check_param "$2"
        tar_package
        query_access
        send_package
        send_case_name "$targetCase"
        run_case
        copy_log
        finish_access
        ;;
    "-d")
        check_env
        tar_package
        query_access
        send_package
        run_case "$1"
        finish_access
        ;;
    "-r")
        check_env
        check_param "$2"
        query_access
        send_target_case
        send_case_name "$2"
        run_case "$1"
        copy_log
        finish_access
        ;;
    "-c")
        check_env
        check_param "$2"
        query_access
        send_target_case
        send_case_name "$2"
        run_case "$1"
        copy_log
        finish_access
        ;;
    "-h")
        show_help
        ;;
    *)
        show_prompt
        ;;
esac
