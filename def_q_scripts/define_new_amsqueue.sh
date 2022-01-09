#!/bin/bash
# Default options                             corresponding flag
queue_name=''                               # -n 
remote_user=''                              # -u
remote_host='submit.aci.ics.psu.edu'        # -h
remote_queue_allocation='open'              # -a
queue_walltime='4:00:00'                    # -w
remote_job_dir='$HOME/scratch/AMSjobs/'     # -d
remote_run_command=''                       # -r
remote_prolog_command=''
                                            # -p
remote_epilog_commad=''                     # -e
skip_confirmation=false                     # -c

# Default arguments
queue_nodes=''
queue_ppn=''


# Parsing script options and flags,
declare -a args=()
arg_index=1
num_args=$#
i=1
while [ $arg_index -le $num_args ]
do  
    if [[ "${!arg_index}" =~ -n ]]; then
        arg_index=$((arg_index+1))
        queue_name=${!arg_index}
    elif [[ "${!arg_index}" =~ -u ]]; then
        arg_index=$((arg_index+1))
        remote_user=${!arg_index}
    elif [[ "${!arg_index}" =~ -h ]]; then
        arg_index=$((arg_index+1))
        remote_host=${!arg_index}
    elif [[ "${!arg_index}" =~ -a ]]; then
        arg_index=$((arg_index+1))
        remote_queue_allocation=${!arg_index}
    elif [[ "${!arg_index}" =~ -w ]]; then
        arg_index=$((arg_index+1))
        queue_walltime=${!arg_index}
    elif [[ "${!arg_index}" =~ -d ]]; then
        arg_index=$((arg_index+1))
        remote_job_dir=${!arg_index}
    elif [[ "${!arg_index}" =~ -r ]]; then
        arg_index=$((arg_index+1))
        remote_run_command=${!arg_index}
    elif [[ "${!arg_index}" =~ -p ]]; then
        arg_index=$((arg_index+1))
        remote_prolog_command=${!arg_index}
    elif [[ "${!arg_index}" =~ -e ]]; then
        arg_index=$((arg_index+1))
        remote_epilog_commad=${!arg_index}
    elif [[ "${!arg_index}" =~ -c ]]; then
        skip_confirmation=true
    elif [[ "${!arg_index}" =~ -.+ ]]; then
        echo -e '\nUnknown flag "-$flag" encountered.'
        echo "Allowed flags,"
        echo "-n <queue name>"
        echo "-u <remote username>"
        echo "-h <remote_host>"
        echo "-a <remote queue allocation>"
        echo "-w <queue default walltime>"
        echo "-d <remote job directory>"
        echo "-r <remote run command>"
        echo "-p <remote prolog command>"
        echo "-e <remote epilog command>"
        echo -e "-z <skip confirmation>.\n"
        exit 1
    else
        args+=("${!arg_index}")
    fi
    arg_index=$((arg_index+1))
done

# Parsing script arguments
num_args="${#args[@]}"


echo "queue_walltime=$queue_walltime"
echo "args:${args[@]}"
for arg in "${args[@]}"
do
    echo $arg
done

# echo "Creating AMS GUI queue for remote job submissions to Penn State's Roar Super Compters."
# echo "Please verify the given inputs,"
# Q_NODES
# Q_PPN
# Q_ALLOCATION
# Q_NAME -n
# USER_NAME -u
# Q_WALLTIME -w
# REM_JOBDIR -d
# SKIP_CONFIRM -c

# echo $input_count