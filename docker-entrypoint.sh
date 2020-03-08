#!/bin/sh
set -e


# allow JVM options to be set from outside
if [ -z "$JAVA_OPTS" ] ; then
    JAVA_OPTS="-Xmx1024M"
fi


gitblit_etc=$GITBLIT_VAR/etc
gitblit_docker=$gitblit_etc/gitblit-docker.properties
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


# Make sure the data volume is populated and writeable.
fill_volume ()
{
    # Copy config files etc.
    if [ ! -e ${gitblit_etc} ] ; then
        mkdir -p ${gitblit_etc}
        [ "$(id -u)" = '0' ] && chown -f gitblit:gitblit ${gitblit_etc}
    fi

    for entry in $(ls /opt/gitblit/vog-etc) ; do
        if [ -L /opt/gitblit/vog-etc/$entry ] || [ -f /opt/gitblit/vog-etc/$entry ]; then
            if [ ! -e ${gitblit_etc}/$entry ] ; then
                cp -dp /opt/gitblit/vog-etc/$entry $gitblit_etc/
            fi
        elif [ -d /opt/gitblit/vog-etc/$entry ] ; then
            if [ ! -e ${gitblit_etc}/$entry ] ; then
                mkdir -p $gitblit_etc/$entry
                [ "$(id -u)" = '0' ] && chown -f gitblit:gitblit ${gitblit_etc}/$entry
            fi

            for file in $(ls /opt/gitblit/vog-etc/${entry}) ; do
                if [ ! -e ${gitblit_etc}/${entry}/$file ] ; then
                    cp -a /opt/gitblit/vog-etc/${entry}/$file $gitblit_etc/$entry/
                fi
            done
        fi
    done

    # Unconditionally copy over the defaults.properties file, so that new settings
    # are in there when Gitblit is upgraded. This file is not to be edited by the
    # user and only serves a  s a reference, so verwriting it is okay. =)
    cp -dp /opt/gitblit/vog-etc/defaults.properties $gitblit_etc/ || true



    # Copy the project.mkd template
    if [ ! -e ${GITBLIT_VAR}/srv/git ] ; then
        mkdir -p ${GITBLIT_VAR}/srv/git
        [ "$(id -u)" = '0' ] && chown -f gitblit:gitblit ${GITBLIT_VAR}/srv/git
    fi

    if [ ! -e ${GITBLIT_VAR}/srv/git/project.mkd ] ; then
        cp -dp /opt/gitblit/srv-project.mkd ${GITBLIT_VAR}/srv/git/project.mkd
    fi


    # Our default for temporary files should exist
    if [ ! -e ${GITBLIT_VAR}/temp ] ; then
        mkdir -p ${GITBLIT_VAR}/temp
        [ "$(id -u)" = '0' ] && chown -f gitblit:gitblit ${GITBLIT_VAR}/temp
    fi




    # If we are running as root, ensure that gitblit owns everything and fix permissions
    if [ "$(id -u)" = '0' ] ; then
        find ${GITBLIT_VAR} \! -user gitblit -exec chown gitblit '{}' +
        find ${GITBLIT_VAR} -type d \! -perm -0700 -exec chmod u+rwxs '{}' +
        find ${GITBLIT_VAR} -type f \! -perm -0600 -exec chmod u+rw   '{}' +
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
    echo "$*" | grep -q -- "--baseFolder" || baseFolder="--baseFolder $gitblit_etc"
    set -- $gitblit $baseFolder "$@"


    # populate volume and adjust permissions
    fill_volume


    # set RPC settings
    set_rpc


    # allow the container to be started with `--user`
    if [ "$(id -u)" = '0' ]; then
        runas gitblit "$@"
    fi
fi


# either run gitblit, if started with --user, or whatever else was given as a command
exec  "$@"
