#!/bin/sh
set -e


# allow JVM options to be set from outside
if [ -z "$JAVA_OPTS" ] ; then
    JAVA_OPTS="-Xmx1024M"
fi


gitblit_docker=$GITBLIT_VAR/etc/gitblit-docker.properties
gitblit_path=/opt/gitblit
gitblit="java -server $JAVA_OPTS -Djava.awt.headless=true -cp ${gitblit_path}/gitblit.jar:${gitblit_path}/ext/* com.gitblit.GitBlitServer"


# Sets settings in gitblit-docker.properties file
# First argument is the key name, second is the value
set_ting ()
{
    key=$1
    val=$2

    if grep -q $key $gitblit_docker ; then
        sed -i -e "s/^$key.*/$key = $val/" $gitblit_docker
    else
    	echo $key = $val >> $gitblit_docker
    fi
}



set_rpc ()
{
    if [ -n "$GITBLIT_RPC" ] ; then
        case $GITBLIT_RPC in 
            off)
                set_ting web.enableRpcServlet false
                set_ting web.enableRpcManagement false
                set_ting web.enableRpcAdministration false
                ;;
            on)
                set_ting web.enableRpcServlet true
                set_ting web.enableRpcManagement false
                set_ting web.enableRpcAdministration false
                ;;
            mgmt|mgmnt)
                set_ting web.enableRpcServlet true
                set_ting web.enableRpcManagement true
                set_ting web.enableRpcAdministration false
                ;;
            admin)
                set_ting web.enableRpcServlet true
                set_ting web.enableRpcManagement true
                set_ting web.enableRpcAdministration true
                ;;
            *)
                echo "ERROR: Invalid value for GITBLIT_RPC: $GITBLIT_RPC"
                exit 1
                ;;
        esac
    fi
}



# use gosu or su-exec to step down from root
runas ()
{
    command -v su-exec > /dev/null && exec su-exec "$@"

    command -v gosu > /dev/null && exec gosu "$@"

    echo "Could not find any program to drop root priviledges. Exiting."
    exit 1
}



# check if arguments are cmdline parameters. then we start gitblit with these parameters.
# first arg is --option or -something
if [ "${1#-}" != "$1" ] ; then
    set -- gitblit "$@"
fi


# if we should run gitblit, replace with the java command
if [ "$1" = 'gitblit' ]; then
    shift
    # if no base folder is given, set the one in our docker default
    baseFolder=
    echo "$*" | grep -q -- "--baseFolder" || baseFolder="--baseFolder $GITBLIT_VAR/etc"
    set -- $gitblit $baseFolder "$@"


    # set RPC settings
    set_rpc


    # allow the container to be started with `--user`
    if [ "$(id -u)" = '0' ]; then
        runas gitblit "$@"
    fi
fi


# either run gitblit, if started with --user, or whatever else was given as a command
exec  "$@"
