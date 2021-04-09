#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/detect_os.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script tested on OS: CentOS 7.x
# Script purpose: Detect running OS
#--------------------------------------------------

set -ex

# Identify installed OS
detect_os ()
{
    if [[ ( -z "${os}" ) && ( -z "${dist}" ) ]]; then
        if [ -e /etc/os-release ]; then
            . /etc/os-release
            os=${ID}
            if [ "${os}" = "poky" ]; then
                dist=`echo ${VERSION_ID}`
                elif [ "${os}" = "sles" ]; then
                dist=`echo ${VERSION_ID}`
                elif [ "${os}" = "opensuse" ]; then
                dist=`echo ${VERSION_ID}`
                elif [ "${os}" = "opensuse-leap" ]; then
                os=opensuse
                dist=`echo ${VERSION_ID}`
            else
                dist=`echo ${VERSION_ID} | awk -F '.' '{ print $1 }'`
            fi
            
            elif [ `which lsb_release 2>/dev/null` ]; then
            # get major version (e.g. '5' or '6')
            dist=`lsb_release -r | cut -f2 | awk -F '.' '{ print $1 }'`
            
            # get os (e.g. 'centos', 'redhatenterpriseserver', etc)
            os=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`
            
            elif [ -e /etc/oracle-release ]; then
            dist=`cut -f5 --delimiter=' ' /etc/oracle-release | awk -F '.' '{ print $1 }'`
            os='ol'
            
            elif [ -e /etc/fedora-release ]; then
            dist=`cut -f3 --delimiter=' ' /etc/fedora-release`
            os='fedora'
            
            elif [ -e /etc/redhat-release ]; then
            os_hint=`cat /etc/redhat-release  | awk '{ print tolower($1) }'`
            if [ "${os_hint}" = "centos" ]; then
                dist=`cat /etc/redhat-release | awk '{ print $3 }' | awk -F '.' '{ print $1 }'`
                os='centos'
                elif [ "${os_hint}" = "scientific" ]; then
                dist=`cat /etc/redhat-release | awk '{ print $4 }' | awk -F '.' '{ print $1 }'`
                os='scientific'
            else
                dist=`cat /etc/redhat-release  | awk '{ print tolower($7) }' | cut -f1 --delimiter='.'`
                os='redhatenterpriseserver'
            fi
            
        else
            aws=`grep -q Amazon /etc/issue`
            if [ "$?" = "0" ]; then
                dist='6'
                os='aws'
            else
                unknown_os
            fi
        fi
    fi
    
    if [[ ( -z "${os}" ) || ( -z "${dist}" ) ]]; then
        unknown_os
    fi
    
    # remove whitespace from OS and dist name
    os="${os// /}"
    dist="${dist// /}"
    
    echo "Detected operating system as ${os}/${dist}."
}