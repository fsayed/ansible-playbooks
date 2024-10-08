#!/bin/sh
#
# check_ssl_cert
#
# Checks an X.509 certificate:
# - checks if the server is running and delivers a valid certificate
# - checks if the CA matches a given pattern
# - checks the validity
#
# See  the INSTALL file for installation instructions
#
# Copyright (c) 2007-2011 ETH Zurich.
#
# This module is free software; you can redistribute it and/or modify it
# under the terms of GNU general public license (gpl) version 3.
# See the LICENSE file for details.
#
# RCS information
# enable substitution with:
#   $ svn propset svn:keywords "Id Revision HeadURL Source Date"
#
#   $Id: check_ssl_cert 1229 2011-03-10 16:41:33Z corti $
#   $Revision: 1229 $
#   $HeadURL: https://svn.id.ethz.ch/nagios_plugins/check_ssl_cert/check_ssl_cert $
#   $Date: 2011-03-10 17:41:33 +0100 (Thu, 10 Mar 2011) $

################################################################################
# Constants

VERSION=1.9.1
SHORTNAME="SSL_CERT"

################################################################################
# Functions

################################################################################
# Prints usage information
# Params
#   $1 error message (optional)
usage() {

    if [ -n "$1" ] ; then
        echo "Error: $1" 1>&2
    fi

    #### The following line is 80 characters long (helps to fit the help text in a standard terminal)
    ######--------------------------------------------------------------------------------
        
    echo
    echo "Usage: check_ssl_cert -H host [OPTIONS]"
    echo
    echo "Arguments:"
    echo "   -H,--host host         server"
    echo
    echo "Options:"
    echo "   -A,--noauth            ignore authority warnings (expiration only)"
    echo "   -c,--critical days     minimum number of days a certificate has to be valid"
    echo "                          to issue a critical status"
    echo "   -e,--email address     pattern to match the email address contained in the"
    echo "                          certificate"
    echo "   -f,--file file         local file path (works with -H localhost only)"
    echo "   -h,--help,-?           this help message"
    echo "   -i,--issuer issuer     pattern to match the issuer of the certificate"
    echo "   -n,---cn name          pattern to match the CN of the certificate"
    echo "   -N,--host-cn           match CN with the host name"
    echo "   -o,--org org           pattern to match the organization of the certificate"
    echo "      --openssl path      path of the openssl binary to be used"
    echo "   -p,--port port         TCP port"
    echo "   -P,--protocol protocol use the specific protocol {http|smtp|pop3|imap|ftp}"
    echo "                          http:               default"
    echo "                          smtp,pop3,imap,ftp: switch to TLS"
    echo "   -s,--selfsigned        allows self-signed certificates"
    echo "   -r,--rootcert path     root certificate or directory to be used for"
    echo "                          certficate validation"
    echo "   -t,--timeout           seconds timeout after the specified time"
    echo "                          (defaults to 15 seconds)"
    echo "      --temp dir          directory where to store the temporary files"
    echo "   -v,--verbose           verbose output"
    echo "   -V,--version           version"
    echo "   -w,--warning days      minimum number of days a certificate has to be valid"
    echo "                          to issue a warning status"
    echo
    echo "Deprecated options:"
    echo "   -d,--days days         minimum number of days a certificate has to be valid"
    echo "                          (see --critical and --warning)"
    echo
    echo "Report bugs to: Matteo Corti <matteo.corti@id.ethz.ch>"
    echo

    exit 3

}

################################################################################
# Exits with a critical message
# Params
#   $1 error message
critical() {
    if [ -n "${CN}" ] ; then
        tmp=" ${CN}"
    fi
    printf "${SHORTNAME} CRITICAL$tmp: $1\n"
    exit 2
}

################################################################################
# Exits with a warning message
# Param
#   $1 warning message
warning() {
    if [ -n "${CN}" ] ; then
        tmp=" ${CN}"
    fi
    printf "${SHORTNAME} WARN$tmp: $1\n"
    exit 1
}

################################################################################
# Exits with an 'unkown' status
# Param
#   $1 message
unknown() {
    if [ -n "${CN}" ] ; then
        tmp=" ${CN}"
    fi
    printf "${SHORTNAME} UNKNOWN$tmp: $1\n"
    exit 3
}

################################################################################
# Executes command with a timeout
# Params:
#   $1 timeout in seconds
#   $2 command
# Returns 1 if timed out 0 otherwise
timeout() {

    time=$1

    # start the command in a subshell to avoid problem with pipes
    # (spawn accepts one command)
    command="/bin/sh -c \"$2\""

    if [ -n "${EXPECT}" ] ; then
        expect -c "set echo \"-noecho\"; set timeout $time; spawn -noecho $command; expect timeout { exit 1 } eof { exit 0 }"    

        if [ $? = 1 ] ; then
            critical "Timeout after $TIMEOUT seconds"
        fi

    else
        eval ${command}
    fi
            
}

################################################################################
# Checks if a given program is available and executable
# Params
#   $1 program name
# Returns 1 if the program exists and is executable
check_required_prog() {

    PROG=$(which $1 2> /dev/null)

    if [ -z "$PROG" ] ; then
        critical "cannot find $1"
    fi

    if [ ! -x "$PROG" ] ; then
        critical "$PROG is not executable"
    fi

}

################################################################################
# Main
################################################################################

# default values
PORT=443
TIMEOUT=15
VERBOSE=""
OPENSSL=""

# set the default temp dir if not set
if [ -z "${TMPDIR}" ] ; then
    TMPDIR="/tmp"
fi

################################################################################
# process command line options
#
#   we do no use getopts since it is unable to process long options

while true; do

    case "$1" in

        ########################################
        # options without arguments

        -A|--noauth)     NOAUTH=1;               shift  ;;

        -h|--help|-\?)   usage;                  exit 0 ;;

        -N|--host-cn)    COMMON_NAME="__HOST__"; shift  ;;

        -s|--selfsigned) SELFSIGNED=1;           shift  ;;
                
        -v|--verbose)    VERBOSE=1;              shift  ;;
        
        -V|--version)    echo "check_ssl_cert version ${VERSION}"; exit 3; ;;

        ########################################
        # options with arguments
        
        -c|--critical) if [ $# -gt 1 ]; then
              CRITICAL=$2; shift 2             
            else 
              unknown "-c,--critical requires an argument"
              fi ;;

        # deprecated option: used to be as --warning
        -d|--days) if [ $# -gt 1 ]; then
              WARNING=$2; shift 2             
            else 
              unknown "-d,--days requires an argument"
            fi ;;

        -e|--email) if [ $# -gt 1 ]; then
              ADDR=$2; shift 2             
            else 
              unknown "-e,--email requires an argument"
            fi ;;

        -f|--file) if [ $# -gt 1 ]; then
              FILE=$2; shift 2
            else 
              unknown "-f,--file requires an argument"
            fi ;;
            
        -H|--host) if [ $# -gt 1 ]; then
              HOST=$2; shift 2
            else 
              unknown "-H,--host requires an argument"
            fi ;;

        -i|--issuer) if [ $# -gt 1 ]; then
              ISSUER=$2; shift 2
            else 
              unknown "-i,--issuer requires an argument"
            fi ;;

        -n|--cn) if [ $# -gt 1 ]; then
              COMMON_NAME=$2; shift 2
            else 
              unknown "-n,--cn requires an argument"
            fi ;;


        -o|--org) if [ $# -gt 1 ]; then
              ORGANIZATION=$2; shift 2
            else 
              unknown "-o,--org requires an argument"
            fi ;;

        --openssl) if [ $# -gt 1 ]; then
              OPENSSL=$2; shift 2
            else
              unknown "--openssl requires an argument"
            fi ;;

        -p|--port) if [ $# -gt 1 ]; then
              PORT=$2; shift 2
            else 
              unknown "-p,--port requires an argument"
            fi ;;

        -P|--protocol) if [ $# -gt 1 ]; then
              PROTOCOL=$2; shift 2
            else 
              unknown "-P,--protocol requires an argument"
            fi ;;

        -r|--rootcert) if [ $# -gt 1 ]; then
              ROOT_CA=$2; shift 2
            else 
              unknown "-r,--rootcert requires an argument"
            fi ;;

        -t|--timeout) if [ $# -gt 1 ]; then
              TIMEOUT=$2; shift 2
            else 
              unknown "-t,--timeout requires an argument"
            fi ;;

        --temp) if [ $# -gt 1 ] ; then
              # override TMPDIR
              TMPDIR=$2; shift 2
            else
              unknown "--temp requires an argument"
            fi ;;

        -w|--warning) if [ $# -gt 1 ]; then
              WARNING=$2; shift 2             
            else 
              unknown "-w,--warning requires an argument"
            fi ;;

        ########################################
        # special
        
        --) shift; break;;
        -*) unknown "invalid option: $1" ;;
        *)  break;;
        
    esac

done

################################################################################
# Set COMMON_NAME to hostname if -N was given as argument
if [ "$COMMON_NAME" = "__HOST__" ]; then
    COMMON_NAME=$(hostname)
fi

################################################################################
# sanity checks

###############
# Check options
if [ -z "${HOST}" ] ; then
    usage "No host specified"
fi

if [ -n "${ROOT_CA}" ] ; then
    if [ ! -r ${ROOT_CA} ] ; then
        unknown "Cannot read root certificate ${ROOT_CA}"
    fi
    if [ -d ${ROOT_CA} ] ; then
      ROOT_CA="-CApath ${ROOT_CA}"
    elif [ -f ${ROOT_CA} ] ; then
      ROOT_CA="-CAfile ${ROOT_CA}"
    else
      unknown "Root certificate of unknown type $(file ${ROOT_CA} 2> /dev/null)"
    fi
fi

if [ -n "${CRITICAL}" ] ; then
    if ! echo "${CRITICAL}" | grep -q '[0-9][0-9]*' ; then
        unknown "invalid number of days ${CRITICAL}"
    fi
fi

if [ -n "${WARNING}" ] ; then
    if ! echo ${WARNING} | grep -q '[0-9][0-9]*' ; then
        unknown "invalid number of days ${WARNING}"
    fi
fi

if [ -n "${CRITICAL}" -a -n "${WARNING}" ] ; then
    if [ ${WARNING} -le ${CRITICAL} ] ; then
        unknown "--warning (${WARNING}) is less than or equal to --critical (${CRITICAL})"
    fi
fi

if [ -n "${TMPDIR}" ] ; then
    if [ ! -d ${TMPDIR} ] ; then
        unknown "${TMPDIR} is not a directory";
    fi
    if [ ! -w ${TMPDIR} ] ; then
        unknown "${TMPDIR} is not writable";
    fi
fi

if [ -n "${OPENSSL}" ] ; then
    if [ ! -x ${OPENSSL} ] ; then
        unknown "${OPENSSL} ist not an executable"
    fi
    if [ $(basename ${OPENSSL}) != 'openssl' ] ; then
        unknown "${OPENSSL} ist not an openssl executable"
    fi
fi
    

#######################
# Check needed programs

if [ -z "${OPENSSL}" ] ; then
    check_required_prog openssl
    OPENSSL=$PROG
fi

EXPECT=$(which expect 2> /dev/null)
test -x "${EXPECT}" || EXPECT=""
if [ -z "${EXPECT}" -a -n "${VERBOSE}" ] ; then
    echo "Expect not found: disabling timeouts"
fi

################################################################################
# check if openssl s_client supports the -servername option
#
#   openssl s_client does not have a -help option
#   => we supply an invalid command line option to get the help
#      on standard error
#
SERVERNAME=
if ${OPENSSL} s_client not_a_real_option 2>&1 | grep -q -- -servername ; then
    SERVERNAME="-servername ${HOST}"
else
    if [ -n "${VERBOSE}" ] ; then
        echo "'${OPENSSL} s_client' does not support '-servername': disabling virtual server support"
    fi
fi

################################################################################
# fetch the X.509 certificate

# temporary storage for the certificate and the errors

CERT=$(  mktemp -t "$( basename $0 )XXXXXX" 2> /dev/null )
if [ -z "${CERT}" ] || [ ! -w "${CERT}" ] ; then
    unknown 'temporary file creation failure.'
fi

ERROR=$( mktemp -t "$( basename $0 )XXXXXX" 2> /dev/null )
if [ -z "${ERROR}" ] || [ ! -w "${ERROR}" ] ; then
    unknown 'temporary file creation failure.'
fi

if [ -n "${VERBOSE}" ] ; then
    echo "downloading certificate to ${TMPDIR}"
fi

# cleanup before program termination
# using named signals to be POSIX compliant
trap "rm -f $CERT $ERROR" EXIT HUP INT QUIT TERM

# check if a protocol was specified (if not HTTP switch to TLS)
if [ -n "${PROTOCOL}" -a "${PROTOCOL}" != "http" -a "${PROTOCOL}" != "https" ] ; then

    case "${PROTOCOL}" in

        smtp|pop3|imap|ftp)

        timeout $TIMEOUT "echo 'Q' | $OPENSSL s_client -starttls ${PROTOCOL} -connect $HOST:$PORT ${SERVERNAME} -verify 6 ${ROOT_CA} 2> ${ERROR} 1> ${CERT}"
        ;;
    
        *)

        unknown "Error: unsupported protocol ${PROTOCOL}"

    esac

elif [ -n "${FILE}" ] ; then

    if [ "${HOST}" = "localhost" ] ; then

        timeout $TIMEOUT "/bin/cat '${FILE}' 2> ${ERROR} 1> ${CERT}"

    else

        unknown "Error: option 'file' works with -H localhost only"

    fi

else

    timeout $TIMEOUT "echo 'Q' | $OPENSSL s_client -connect $HOST:$PORT ${SERVERNAME} -verify 6 ${ROOT_CA} 2> ${ERROR} 1> ${CERT}"
    
fi

if [ $? -ne 0 ] ; then
    critical "Error: $(head -n 1 ${ERROR})"
fi

################################################################################
# parse the X.509 certificate

DATE=$($OPENSSL x509 -inform der -in ${CERT} -inform der -enddate -noout | sed -e "s/^notAfter=//")
CN=$($OPENSSL x509 -inform der -in ${CERT} -inform der -subject -noout | sed -e "s/^.*\/CN=//" -e "s/\/[A-Za-z][A-Za-z]*=.*$//")

CA_O=$($OPENSSL x509 -inform der -in ${CERT} -inform der -issuer -noout | sed -e "s/^.*\/O=//" -e "s/\/[A-Z][A-Z]*=.*$//")
CA_CN=$($OPENSSL x509 -inform der -in ${CERT} -inform der -issuer -noout  | sed -e "s/^.*\/CN=//" -e "s/\/[A-Za-z][A-Za-z]*=.*$//")

################################################################################
# check the CN (this will not work as expected with wildcard certificates)

if [ -n "$COMMON_NAME" ] ; then

    ok=''

    case $COMMON_NAME in
        $CN) ok='true';;
    esac

    if [ -z "$ok" ] ; then
        critical "invalid CN ('$CN' does not match '$COMMON_NAME')"
    fi
    
fi

################################################################################
# check the issuer

if [ -n "$ISSUER" ] ; then

    ok=''
    CA_ISSUER_MATCHED=''

    if echo $CA_CN | grep -q "^$ISSUER$" ; then
        ok='true'
        CA_ISSUER_MATCHED="${CA_CN}"
    fi

    if echo $CA_O | grep -q "^$ISSUER$" ; then
        ok='true'
        CA_ISSUER_MATCHED="${CA_O}"
    fi

    if [ -z "$ok" ] ; then
        critical "invalid CA ('$ISSUER' does not match '$CA_O' or '$CA_CN')"
    fi
    
else

    CA_ISSUER_MATCHED="${CA_CN}"

fi

################################################################################
# check the validity

# we always check expired certificates
if ! $OPENSSL x509 -inform der -inform der -in ${CERT} -noout -checkend 0 ; then
    critical "certificate is expired (was valid until $DATE)"
fi

if [ -n "${CRITICAL}" ] ; then

    if ! $OPENSSL x509 -inform der -in ${CERT} -noout -checkend $(( ${CRITICAL} * 86400 )) ; then
        critical "certificate will expire on $DATE"
    fi

fi

if [ -n "${WARNING}" ] ; then

    if ! $OPENSSL x509 -inform der -in ${CERT} -noout -checkend $(( ${WARNING} * 86400 )) ; then
        warning "certificate will expire on $DATE"
    fi

fi

################################################################################
# check the organization

if [ -n "$ORGANIZATION" ] ; then

    ORG=$($OPENSSL x509 -inform der -in ${CERT} -subject -noout | sed -e "s/.*\/O=//" -e "s/\/.*//")

    if ! echo $ORG | grep -q "^$ORGANIZATION" ; then
        critical "invalid organization ('$ORGANIZATION' does not match '$ORG')"
    fi

fi

################################################################################
# check the organization

if [ -n "$ADDR" ] ; then

    EMAIL=$($OPENSSL x509 -inform der -in ${CERT} -email -noout)

    if [ -n "${VERBOSE}" ] ; then
        echo "checking email (${ADDR}): ${EMAIL}"
    fi

    if [ -z "${EMAIL}" ] ; then
        critical "the certficate does not contain an email address"
    fi

    if ! echo $EMAIL | grep -q "^$ADDR" ; then
        critical "invalid email ($ADDR does not match $EMAIL)"
    fi

fi

################################################################################
# Check if the certificate was verified

if [ -z "${NOAUTH}" ] && grep -q '^verify\ error:' ${ERROR} ; then

    if grep -q '^verify\ error:num=18:self\ signed\ certificate' ${ERROR} ; then

        if [ -z "${SELFSIGNED}" ] ; then
            critical "Cannot verify certificate\nself signed certificate"
        else
            SELFSIGNEDCERT="self signed "
        fi

    else 

        # process errors
        details=$(grep  '^verify\ error:' ${ERROR} | sed -e "s/verify\ error:num=[0-9]*:/verification error: /" )

        critical "Cannot verify certificate\n${details}"

    fi
    
fi

################################################################################
# If we get this far, assume all is well. :)
echo "${SHORTNAME} OK - X.509 ${SELFSIGNEDCERT}certificate for '$CN' from '$CA_ISSUER_MATCHED' valid until $DATE"

exit 0
