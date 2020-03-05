#!/bin/sh
set -e


# allow JVM options to be set from outside
if [ -z "$JAVA_OPTS" ] ; then
	JAVA_OPTS="-Xmx1024M"
fi


gitblit_path=/opt/gitblit
gitblit="java -server $JAVA_OPTS -Djava.awt.headless=true -cp ${gitblit_path}/gitblit.jar:${gitblit_path}/ext/* com.gitblit.GitBlitServer"


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


    # allow the container to be started with `--user`
    if [ "$(id -u)" = '0' ]; then
        runas gitblit "$@"
    fi
fi


# either run gitblit, if started with --user, or whatever else was given as a command
exec  "$@"
