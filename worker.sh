#!/bin/bash

ONBOARDING_SCRIPT=
SUCCESS=0
ERR_ONBOARDING_FAILED=31

# Predefined values
export DEBIAN_FRONTEND=noninteractive

_log() {
    level="$1"
    dest="$2"
    msg="${@:3}"
    ts=$(date -u +"%Y-%m-%dT%H:%M:%S")

    if [ "$dest" = "stdout" ]; then
       echo "$msg"
    elif [ "$dest" = "stderr" ]; then
       >&2 echo "$msg"
    fi

    if [ -n "$log_path" ]; then
       echo "$ts $level $msg" >> "$log_path"
    fi
}

log_debug() {
    _log "DEBUG" "stdout" "$@"
}

log_info() {
    _log "INFO " "stdout" "$@"
}

log_warning() {
    _log "WARN " "stderr" "$@"
}

log_error() {
    _log "ERROR" "stderr" "$@"
}

script_exit()
{
    if [ -z "$1" ]; then
        log_error "[!] INTERNAL ERROR. script_exit requires an argument"
        exit $ERR_INTERNAL
    fi

    if [ "$2" = "0" ]; then
        log_info "[v] $1"
    else
	    log_error "[x] $1"
    fi

    if [ -z "$2" ]; then
        exit $ERR_INTERNAL
    elif ! [ "$2" -eq "$2" ] 2> /dev/null; then #check error is number
        exit $ERR_INTERNAL
    else
        log_info "[*] exiting ($2)"
	    exit $2
    fi
}

get_python() {
   if which python3 &> /dev/null; then
      echo "python3"
   elif which python2 &> /dev/null; then
      echo "python2"
   else
      echo "python"
   fi
}


parse_uri() {
   cat <<EOF | /usr/bin/env $(get_python)
import sys

if sys.version_info < (3,):
   from urlparse import urlparse
else:
   from urllib.parse import urlparse

uri = urlparse("$1")
print(uri.scheme or "")
print(uri.hostname or "")
print(uri.port or "")
EOF
}

run_quietly()
{
    # run_quietly <command> <error_msg> [<error_code>]
    # use error_code for script_exit

    if [ $# -lt 2 ] || [ $# -gt 3 ]; then
        log_error "[!] INTERNAL ERROR. run_quietly requires 2 or 3 arguments"
        exit 1
    fi

    local out=$(eval $1 2>&1; echo "$?")
    local exit_code=$(echo "$out" | tail -n1)

    if [ -n "$VERBOSE" ]; then
        log_info "$out"
    fi
    
    if [ "$exit_code" -ne 0 ]; then
        if [ -n $DEBUG ]; then             
            log_debug "[>] Running command: $1"
            log_debug "[>] Command output: $out"
            log_debug "[>] Command exit_code: $exit_code"
        fi

        if [ $# -eq 2 ]; then
            log_error $2
        else
            script_exit "$2" "$3"
        fi
    fi

    return $exit_code
}

retry_quietly()
{
    # retry_quietly <retries> <command> <error_msg> [<error_code>]
    # use error_code for script_exit
    
    if [ $# -lt 3 ] || [ $# -gt 4 ]; then
        log_error "[!] INTERNAL ERROR. retry_quietly requires 3 or 4 arguments"
        exit 1
    fi

    local exit_code=
    local retries=$1

    while [ $retries -gt 0 ]
    do

        if run_quietly "$2" "$3"; then
            exit_code=0
        else
            exit_code=1
        fi
        
        if [ $exit_code -ne 0 ]; then
            sleep 1
            ((retries--))
            log_info "[r] $(($1-$retries))/$1"
        else
            retries=0
        fi
    done

    if [ $# -eq 4 ] && [ $exit_code -ne 0 ]; then
        script_exit "$3" "$4"
    fi

    return $exit_code
}


detect_arch()
{
    arch=$(uname -m)
    if  [[ "$arch" =~ arm* ]]; then
        script_exit "ARM architecture is not yet supported by the script" $ERR_UNSUPPORTED_ARCH
    fi
}

detect_distro()
{
    if [ -f /etc/os-release ] || [ -f /etc/mariner-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        VERSION_NAME=$VERSION_CODENAME
    elif [ -f /etc/redhat-release ]; then
        if [ -f /etc/oracle-release ]; then
            DISTRO="ol"
        elif [[ $(grep -o -i "Red\ Hat" /etc/redhat-release) ]]; then
            DISTRO="rhel"
        elif [[ $(grep -o -i "Centos" /etc/redhat-release) ]]; then
            DISTRO="centos"
        fi
        VERSION=$(grep -o "release .*" /etc/redhat-release | cut -d ' ' -f2)
    else
        script_exit "unable to detect distro" $ERR_UNSUPPORTED_DISTRO
    fi

    # change distro to ubuntu for linux mint support
    if [ "$DISTRO" == "linuxmint" ]; then
        DISTRO="ubuntu"
    fi

    if [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "ubuntu" ]; then
        DISTRO_FAMILY="debian"
    elif [ "$DISTRO" == "rhel" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "ol" ] || [ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "amzn" ]; then
        DISTRO_FAMILY="fedora"
    elif [ "$DISTRO" == "mariner" ]; then
        DISTRO_FAMILY="mariner"
    elif [ "$DISTRO" == "sles" ] || [ "$DISTRO" == "sle-hpc" ] || [ "$DISTRO" == "sles_sap" ]; then
        DISTRO_FAMILY="sles"
    else
        script_exit "unsupported distro $DISTRO $VERSION" $ERR_UNSUPPORTED_DISTRO
    fi

    log_info "[>] detected: $DISTRO $VERSION $VERSION_NAME ($DISTRO_FAMILY)"
}

verify_channel()
{
    if [ "$CHANNEL" != "prod" ] && [ "$CHANNEL" != "insiders-fast" ] && [ "$CHANNEL" != "insiders-slow" ]; then
        script_exit "Invalid channel: $CHANNEL. Please provide valid channel. Available channels are prod, insiders-fast, insiders-slow" $ERR_INVALID_CHANNEL
    fi
}

set_package_manager()
{
    if [ "$DISTRO_FAMILY" = "debian" ]; then
        PKG_MGR=apt
        PKG_MGR_INVOKER="apt $ASSUMEYES"
    elif [ "$DISTRO_FAMILY" = "fedora" ]; then
        PKG_MGR=yum
        PKG_MGR_INVOKER="yum $ASSUMEYES"
    elif [ "$DISTRO_FAMILY" = "mariner" ]; then
        PKG_MGR=dnf
        PKG_MGR_INVOKER="dnf $ASSUMEYES"
    elif [ "$DISTRO_FAMILY" = "sles" ]; then
        DISTRO="sles"
        PKG_MGR="zypper"
        PKG_MGR_INVOKER="zypper --non-interactive"
    else    
        script_exit "unsupported distro", $ERR_UNSUPPORTED_DISTRO
    fi

    log_info "[v] set package manager: $PKG_MGR"
}

check_if_pkg_is_installed()
{
    if [ -z "$1" ]; then
        script_exit "INTERNAL ERROR. check_if_pkg_is_installed requires an argument" $ERR_INTERNAL
    fi

    if [ "$PKG_MGR" = "apt" ]; then
        dpkg -s $1 2> /dev/null | grep Status | grep "install ok installed" 1> /dev/null
    else
        rpm --quiet --query $(get_rpm_proxy_params) $1
    fi

    return $?
}

install_required_pkgs()
{
    local packages=
    local pkgs_to_be_installed=

    if [ -z "$1" ]; then
        script_exit "INTERNAL ERROR. install_required_pkgs requires an argument" $ERR_INTERNAL
    fi

    packages=("$@")
    for pkg in "${packages[@]}"
    do
        if  ! check_if_pkg_is_installed $pkg; then
            pkgs_to_be_installed="$pkgs_to_be_installed $pkg"
        fi
    done

    if [ ! -z "$pkgs_to_be_installed" ]; then
        log_info "[>] installing $pkgs_to_be_installed"
        run_quietly "$PKG_MGR_INVOKER install $pkgs_to_be_installed" "Unable to install the required packages ($?)" $ERR_FAILED_DEPENDENCY 
    else
        log_info "[v] required pkgs are installed"
    fi
}

wait_for_package_manager_to_complete()
{
    local lines=
    local counter=120

    while [ $counter -gt 0 ]
    do
        lines=$(ps axo pid,comm | grep "$PKG_MGR" | grep -v grep -c)
        if [ "$lines" -eq 0 ]; then
            log_info "[>] package manager freed, resuming installation"
            return
        fi
        sleep 1
        ((counter--))
    done

    log_info "[!] pkg_mgr blocked"
}

onboard_device()
{
    log_info "[>] onboarding script: $ONBOARDING_SCRIPT"

    if [ ! -f $ONBOARDING_SCRIPT ]; then
        script_exit "error: onboarding script not found." $ERR_ONBOARDING_NOT_FOUND
    fi

    if [[ $ONBOARDING_SCRIPT == *.py ]]; then
        # Make sure python is installed
        PYTHON=$(which python || which python3)

        # Run onboarding script
        # echo "[>] running onboarding script..."
        sleep 1
        run_quietly "$PYTHON $ONBOARDING_SCRIPT" "error: python onboarding failed" $ERR_ONBOARDING_FAILED

    # elif [[ $ONBOARDING_SCRIPT == *.sh ]]; then        
    #     run_quietly "sh $ONBOARDING_SCRIPT" "error: bash onboarding failed" $ERR_ONBOARDING_FAILED
    else
        script_exit "error: unknown onboarding script type." $ERR_ONBOARDING_FAILED
    fi
    log_info "[v] onboarded"
}


usage()
{
    echo "worker.sh"
    echo "usage: $1 [OPTIONS]"
    echo "Options:"
    echo " --log-path <PATH>    also log output to PATH"
    echo " -o|--onboard <PATH>  onboard device using script at PATH"
    echo " -h|--help            display help"
}

if [ $# -eq 0 ]; then
    usage
    script_exit "no arguments were provided. specify --help for details" $ERR_INVALID_ARGUMENTS
fi

while [ $# -ne 0 ];
do
    case "$1" in
        -h|--help)
            usage "basename $0" >&2
            exit 0
            ;;
        -o|--onboard)
            if [ -z "$2" ]; then
                script_exit "$1 option requires an argument" $ERR_INVALID_ARGUMENTS
            fi        
            export ONBOARDING_SCRIPT=$2
            shift 2
            ;;
        --base-folder)
            if [[ -z "$2" ]]; then
                script_exit "$1 option requires two arguments" $ERR_INVALID_ARGUMENTS
            fi
            export base_folder="$2"
            export log_path="${base_folder}/install.log"
            shift 2
            ;;
        *)
            echo "use -h or --help for details"
            script_exit "unknown argument" $ERR_INVALID_ARGUMENTS
            ;;
    esac
done

log_info "--- worker.sh  ---"

## Detect the architecture type
detect_arch

### Detect the distro and version number ###
detect_distro

### Set package manager ###
set_package_manager

### Run Onboarding Script ###
onboard_device

log_info "Doing work that takes 5 seconds"
for i in {1..5}; do
    echo  "."
    sleep 1
done
log_info "Done with work"
SUCCESS=0

script_exit "--- worker.sh ended. ---" $SUCCESS