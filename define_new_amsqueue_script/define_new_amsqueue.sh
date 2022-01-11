#!/bin/bash

#  +-+ +-+ +-+ +-+ +-+ +-+ +-+   +-+ +-+ +-+ +-+ +-+ +-+ +-+ #
#  |D| |E| |F| |A| |U| |L| |T|   |O| |P| |T| |I| |O| |N| |S| #
#  +-+ +-+ +-+ +-+ +-+ +-+ +-+   +-+ +-+ +-+ +-+ +-+ +-+ +-+ #

# Default options                             corresponding flag
default_remote_user=''                              # -u
default_remote_host='submit.aci.ics.psu.edu'        # -h
default_allocation='open'                           # -a
default_pmem='4gb'                                  # -p
default_queue_walltime='4:00:00'                    # -w
default_remote_job_dir='$HOME/scratch/AMSjobs/'     # -d
#  +-+ +-+ +-+ +-+ +-+ +-+ +-+   +-+ +-+ +-+ +-+ +-+ +-+ +-+ #
#  |D| |E| |F| |A| |U| |L| |T|   |O| |P| |T| |I| |O| |N| |S| #
#  +-+ +-+ +-+ +-+ +-+ +-+ +-+   +-+ +-+ +-+ +-+ +-+ +-+ +-+ #
skip_confirmation=false                     # -c *Do not change

# Message to display allowed flags
allowed_flags_message="
Allowed flags,\n
\t -n \t <queue name>\n
\t -u \t <remote username>\n
\t -h \t <remote_host>\n
\t -a \t <remote queue allocation>\n
\t -p \t <mem. per node>\n
\t -w \t <queue default walltime>\n
\t -d \t <remote job directory>\n
\t -c \t <skip confirmation>.\n
"

# Parsing script optional flags and arguments,
declare -a args=()
arg_index=1
num_args=$#
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
        allocation=${!arg_index}
    elif [[ "${!arg_index}" =~ -p ]]; then
        arg_index=$((arg_index+1))
        pmem=${!arg_index}
        if [[ "$pmem" != *gb ]]; then
            pmem+="gb"
        fi
    elif [[ "${!arg_index}" =~ -w ]]; then
        arg_index=$((arg_index+1))
        queue_walltime=${!arg_index}
    elif [[ "${!arg_index}" =~ -d ]]; then
        arg_index=$((arg_index+1))
        remote_job_dir=${!arg_index}
    elif [[ "${!arg_index}" =~ -r ]]; then
        arg_index=$((arg_index+1))
        remote_run_command=${!arg_index}
    elif [[ "${!arg_index}" =~ -c ]]; then
        skip_confirmation=true
    elif [[ "${!arg_index}" =~ -.+ ]]; then
        echo -e "\nUnknown flag ${!arg_index} encountered."
        echo -e $allowed_flags_message 
        exit 1
    else
        args+=("${!arg_index}")
    fi
    arg_index=$((arg_index+1))
done

# Parsing script arguments
num_args="${#args[@]}"
if [[ num_args -ne 2 ]]; then
    echo -e "Incorrect number of arguments provided."
    echo -e "Expected 2 arguments. (nodes and processors per node)"
    echo -e "All other arguments must be preceded with appropriate flag."
    echo -e $allowed_flags_message
    exit 1
fi
queue_nodes=${args[0]}
queue_ppn=${args[1]}

# Using defaults for unset options
if [[ -z $remote_user ]]; then
    remote_user=$default_remote_user
fi
if [[ -z $remote_host ]]; then
    remote_host=$default_remote_host
fi
if [[ -z $allocation ]]; then
    allocation=$default_allocation
fi
if [[ -z $pmem ]]; then
    echo e
    pmem=$default_pmem
fi
if [[ -z $queue_walltime ]]; then
    queue_walltime=$default_queue_walltime
fi
if [[ -z $remote_job_dir ]]; then
    remote_job_dir=$default_remote_job_dir
fi
if [[ -z $queue_name ]]; then
    queue_name="${allocation[@]:0:5}_${queue_nodes}_${queue_ppn}"
    queue_name+="_${pmem::-2}"
fi

# Run commands
#  +-+ +-+ +-+   +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+
#  |R| |U| |N|   |C| |O| |M| |M| |A| |N| |D| |S|
#  +-+ +-+ +-+   +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+
queue_run_command="qsub -l nodes=$queue_nodes:ppn=$queue_ppn -A $allocation -l walltime=\$options "
queue_run_command+="-l pmem=$pmem -j oe -z \"\$job\""
queue_prolog_command="module purge;module load ams;cd \$PBS_O_WORKDIR"
queue_epilog_command=""
#  +-+ +-+ +-+   +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+
#  |R| |U| |N|   |C| |O| |M| |M| |A| |N| |D| |S|
#  +-+ +-+ +-+   +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+

# Confirmation message if needed
confirmation_message="
\nPlease verify the following inputs for queue definition,\n
\tQueue name\t\t: $queue_name\n
\tQueue nodes\t\t: $queue_nodes\n
\tQueue ppn\t\t: $queue_ppn\n
\tDefault options\t\t: $queue_walltime\n
\tRemote user\t\t: $remote_user\n
\tRemote job directory\t: $remote_job_dir\n
\tRun command\t\t: $queue_run_command\n
\tProlog command\t\t: $queue_prolog_command\n
\tEpilog command\t\t: $queue_epilog_command\n
"
if [[ $skip_confirmation == "false" ]]; then
    echo -e $confirmation_message
    while true
    do
        read -r -p "Continue? [Y/n] " confirmation
        case $confirmation in
                [yY][eE][sS]|[yY])
                    echo "Creating $queue_name.tid file at \$HOME/.scm_gui."
                    break
                    ;;
                [nN][oO]|[nN])
                    echo -e "\nAborted.\n"
                    exit 1
                    break
                    ;;
                *)
                    echo "Invalid input..."
                    ;;
        esac      
    done
fi

# Check $HOME/.scm_gui exists and create if neccessary
if [[ ! -d $HOME/.scm_gui ]]; then
    mkdir -p $HOME/.scm_gui
fi

# Check if queue with same name exists
queue_file=$HOME/.scm_gui/${queue_name}.tid
if [[ -f $queue_file ]]
then
    echo ""
    while true
    do
        read -r -p "Queue already exists, overwrite? [Y/n] " confirmation
        case $confirmation in
                [yY][eE][sS]|[yY])
                    echo "Overwriting $queue_name.tid file at \$HOME/.scm_gui."
                    break
                    ;;
                [nN][oO]|[nN])
                    echo -e "\nAborted.\n"
                    break
                    ;;
                *)
                    echo "Invalid input..."
                    ;;
        esac      
    done
fi

echo "# backup: 
# batch: no
# cloudid: 
# cloudinit: 
# comparewithtarget: changed
# copyback: 
# epilog: $queue_epilog_command 
# error: -1
# fakejob: 0
# hostname: $remote_host
# jobdir: $remote_job_dir
# jobscript: 
# jobstatuscmd: qstat \$jid | grep -w \$jid
# jobtype: 
# killcmd: qdel \$jid
# label: $queue_name
# logfile: logfile
# mtime: 
# options: $queue_walltime
# paused: 0
# privatesshkeypath: 
# prolog: $queue_prolog_command
# remoteprefix: 
# runcmd: $queue_run_command
# sysstatuscmd: qstat -q
# username: $remote_user
# warning: 0
" > $queue_file