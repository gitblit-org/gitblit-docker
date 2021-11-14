#!/bin/bash
#
# Full fledged script that can be used with parameters
#
# THIS IS A GENERATED SCRIPT. See the usage section below.
#
usage() {
    cat << USAGE

Generate Gitblit Dockerfiles, either for release or snapshots

Usage: generate_dockerfile.sh [flags]

Options:
  -h, --help
        show help screen
  -v, --version <major.minor.patch>
        the Gitblit version for which the Dockerfile is generated
        Required for releases
  -o, --output-file <filename>
        write to specified file (default: stdout)
  --sha <sha256>
        the SHA-256 hash of the Gitblit release tarball
        Required for release versions
  --tarball <gitblit.tar.gz>
        the Gitblit snapshot tarball file
        Default is ${GITBLIT_FILE} 
  --release
        generate a Dockerfile for a Gitblit release
        Default is to generate a Dockerfile for a snapshot version
  --ubuntu
        generate a Dockerfile for only a Ubuntu based image
        Default is to generate a combined Dockerfile which can be
        used to build Ubuntu and Alpine images
  --alpine
        generate a Dockerfile for only an Alpine based image
        Default is to generate a combined Dockerfile which can be
        used to build Ubuntu and Alpine images

Environment variables:
    GITBLIT_VERSION
    GITBLIT_DOWNLOAD_SHA

Example:
    Generate a Dockerfile to build snapshot images
    $ GITBLIT_VERSION=SNAPSHOT ./generate_dockerfile.sh > Dockerfile
    Generate the Dockerfile for the Alpine image, stored in this repository
    $ ./generate_dockerfile.sh -v 1.10.0 --sha 123...abc --release --alpine -o ../Dockerfile.alpine

This script is generated from the Dockerfile.template with 'bash-tpl'
Regenerate with: $ bash-tpl -- Dockerfile.template > generate_dockerfile.sh
See: https://github.com/TekWizely/bash-tpl

USAGE
}

parse_args() {
    while (($#)); do
        case "$1" in
            -h | --help)
                usage
                exit 0
                ;;
            -o | --output-file)
                if [ -n "${2}" ]; then
                    OUPUT_FILE="${2}"
                else
                    echo "Error: Invalid or missing value for --output-file: '${2}'" >&2
                    exit 1
                fi
                shift 2
                ;;
            -v | --version)
                if [ -n "${2}" ]; then
                    GITBLIT_VERSION="${2}"
                else
                    echo "Error: Invalid or missing value for --version: '${2}'" >&2
                    exit 1
                fi
                shift 2
                ;;
            --sha)
                if [ -n "${2}" ]; then
                    GITBLIT_DOWNLOAD_SHA="${2}"
                else
                    echo "Error: Invalid or missing value for --sha: '${2}'" >&2
                    exit 1
                fi
                shift 2
                ;;
            --tarball)
                if [ -n "${2}" ]; then
                    GITBLIT_FILE="${2}"
                else
                    echo "Error: Invalid or missing value for --tarball: '${2}'" >&2
                    exit 1
                fi
                shift 2
                ;;
            --release)
                IMAGE_TYPE="release"
                shift
                ;;
            --alpine)
                DOCKERFILE_TYPE="alpine"
                shift
                ;;
            --ubuntu)
                DOCKERFILE_TYPE="ubuntu"
                shift
                ;;
            --* | -*) # unsupported flags
                echo "Error: unknown flag: '$1'; use -h for help" >&2
                exit 1
                ;;
            *) # unsupported positional arguments
                echo "Error: unknown argument: '$1'; use -h for help" >&2
                exit 1
                ;;
        esac
    done
}
# Some global defines
#

GITBLIT_VAR=/var/opt/gitblit
: ${GITBLIT_FILE:=gitblit-*-SNAPSHOT.tar.gz}

#
# Parse parameters and check for missing values

parse_args "$@"

if [[ -z "$GITBLIT_VERSION" ]] ; then
    echo "ERROR: You need to define GITBLIT_VERSION" >&2
    exit 1
fi
if [[ -z "$GITBLIT_DOWNLOAD_SHA" && "$IMAGE_TYPE" == release ]] ; then
    echo "ERROR: You  need to define GITBLIT_DOWNLOAD_SHA for a release Dockerfile" >&2
    exit 1
fi

#
# If an outfile was defined, reroute to file

if [[ -n "${OUPUT_FILE}" ]]; then
    exec > "${OUPUT_FILE}"
fi

#
# Here begins the generation of the actual Dockerfile
#
if [[ "$IMAGE_TYPE" == release && "$DOCKERFILE_TYPE" == alpine ]] ; then
printf "%s\n" FROM\ openjdk:8-jre-alpine
printf "\n"
printf "%s\n" \#\ add\ our\ user\ and\ group\ first\ to\ make\ sure\ their\ IDs\ get\ assigned\ consistently\,\ regardless\ of\ whatever\ packages\ get\ added
printf "%s\n" RUN\ addgroup\ -S\ -g\ 8117\ gitblit\ \&\&\ adduser\ -S\ -H\ -G\ gitblit\ -u\ 8117\ -h\ /opt/gitblit\ gitblit
elif [[ "$IMAGE_TYPE" == release && "$DOCKERFILE_TYPE" == ubuntu ]] ; then
printf "%s\n" FROM\ openjdk:8-jre-slim
printf "\n"
printf "%s\n" \#\ add\ our\ user\ and\ group\ first\ to\ make\ sure\ their\ IDs\ get\ assigned\ consistently\,\ regardless\ of\ whatever\ packages\ get\ added
printf "%s\n" RUN\ groupadd\ -r\ -g\ 8117\ gitblit\ \&\&\ useradd\ -r\ -M\ -g\ gitblit\ -u\ 8117\ -d\ /opt/gitblit\ gitblit
else
printf "%s\n" FROM\ openjdk:8-jre-slim\ AS\ base
printf "\n"
printf "%s\n" \#\ add\ our\ user\ and\ group\ first\ to\ make\ sure\ their\ IDs\ get\ assigned\ consistently\,\ regardless\ of\ whatever\ packages\ get\ added
printf "%s\n" RUN\ groupadd\ -r\ -g\ 8117\ gitblit\ \&\&\ useradd\ -r\ -M\ -g\ gitblit\ -u\ 8117\ -d\ /opt/gitblit\ gitblit
fi
printf "\n"
printf "\n"
printf "%s\n" ENV\ GITBLIT_VERSION\ "${GITBLIT_VERSION}"
printf "\n"
if [[ "$IMAGE_TYPE" == release ]] ; then
printf "%s\n" ENV\ GITBLIT_DOWNLOAD_SHA\ "${GITBLIT_DOWNLOAD_SHA}"
printf "%s\n" ENV\ GITBLIT_DOWNLOAD_URL\ https://github.com/gitblit/gitblit/releases/download/v\$\{GITBLIT_VERSION\}/gitblit-\$\{GITBLIT_VERSION\}.tar.gz
printf "\n"
if [[ "$DOCKERFILE_TYPE" == alpine ]] ; then
printf "%s\n" \#\ Install\ su-exec\ to\ step\ down\ from\ root
printf "%s\n" RUN\ set\ -eux\;\ \\
    printf "%s\n" \ \ \ \ apk\ add\ --no-cache\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ \'su-exec\>=0.2\'\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ \;\ \\
    printf "%s\n" \ \ \ \ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Download\ and\ install\ Gitblit
    printf "%s\n" \ \ \ \ wget\ -nv\ -O\ gitblit.tar.gz\ \$\{GITBLIT_DOWNLOAD_URL\}\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"\$\{GITBLIT_DOWNLOAD_SHA\}\ \*gitblit.tar.gz\"\ \|\ sha256sum\ -c\ -\ \;\ \\
    printf "%s\n" \ \ \ \ mkdir\ -p\ /opt/gitblit\ \;\ \\
    printf "%s\n" \ \ \ \ tar\ xzf\ gitblit.tar.gz\ -C\ /opt/gitblit\ --strip-components\ 1\ \;\ \\
    printf "%s\n" \ \ \ \ rm\ -f\ gitblit.tar.gz\ \;\ \\
printf "%s\n" \#\ Remove\ unneeded\ scripts.
    printf "%s\n" \ \ \ \ rm\ -f\ /opt/gitblit/install-service-\*.sh\ \;\ \\
    printf "%s\n" \ \ \ \ rm\ -r\ /opt/gitblit/service-\*.sh\ \;\ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Change\ shell\ to\ \'sh\'\ for\ Alpine
    printf "%s\n" \ \ \ \ for\ file\ in\ /opt/gitblit/\*.sh\ \;\ do\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ sed\ -i\ -e\ \'s\;bin/bash\;bin/sh\;\'\ \$file\ \;\ \\
    printf "%s\n" \ \ \ \ done
printf "\n"
else
printf "%s\n" \#\ Install\ fetch\ dependencies\,\ and\ gsou\ to\ step\ down\ from\ root
printf "%s\n" RUN\ set\ -eux\ \;\ \\
    printf "%s\n" \ \ \ \ apt-get\ update\ \&\&\ apt-get\ install\ -y\ --no-install-recommends\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ wget\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ gosu\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ \;\ \\
    printf "%s\n" \ \ \ \ rm\ -rf\ /var/lib/apt/lists/\*\ \;\ \\
printf "%s\n" \#\ Download\ and\ install\ Gitblit
    printf "%s\n" \ \ \ \ wget\ --progress=bar:force:noscroll\ -O\ gitblit.tar.gz\ \$\{GITBLIT_DOWNLOAD_URL\}\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"\$\{GITBLIT_DOWNLOAD_SHA\}\ \*gitblit.tar.gz\"\ \|\ sha256sum\ -c\ -\ \;\ \\
    printf "%s\n" \ \ \ \ mkdir\ -p\ /opt/gitblit\ \;\ \\
    printf "%s\n" \ \ \ \ tar\ xzf\ gitblit.tar.gz\ -C\ /opt/gitblit\ --strip-components\ 1\ \;\ \\
    printf "%s\n" \ \ \ \ rm\ -f\ gitblit.tar.gz\ \;\ \\
printf "%s\n" \#\ Remove\ unneeded\ scripts.
    printf "%s\n" \ \ \ \ rm\ -f\ /opt/gitblit/install-service-\*.sh\ \;\ \\
    printf "%s\n" \ \ \ \ rm\ -r\ /opt/gitblit/service-\*.sh\ \;\ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ It\ is\ getting\ annoying\ not\ to\ have\ \'ll\'\ and\ colors\ when\ opening\ a\ bash\ in\ the\ container
    printf "%s\n" \ \ \ \ echo\ \"export\ LS_OPTIONS=\'--color=auto\'\"\ \>\>\ /root/.bashrc\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \'eval\ \`dircolors\ -b\`\'\ \>\>\ /root/.bashrc\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"alias\ ls=\'\"\'ls\ \$LS_OPTIONS\'\"\'\"\ \>\>\ /root/.bashrc\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"alias\ ll=\'\"\'ls\ \$LS_OPTIONS\ -l\'\"\'\"\ \>\>\ /root/.bashrc\ \;
fi
printf "\n"
else
printf "\n"
printf "%s\n" ADD\ "${GITBLIT_FILE}"\ /opt/
printf "\n"
printf "%s\n" \#\ Install\ gosu\ to\ step\ down\ from\ root
printf "%s\n" RUN\ set\ -eux\ \;\ \\
    printf "%s\n" \ \ \ \ apt-get\ update\ \&\&\ apt-get\ install\ -y\ --no-install-recommends\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ gosu\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ \;\ \\
    printf "%s\n" \ \ \ \ rm\ -rf\ /var/lib/apt/lists/\*\ \;\ \\
printf "%s\n" \#\ Adjust\ folder\ name\ of\ gitblit\ unpacked\ by\ ADD\ command
    printf "%s\n" \ \ \ \ mv\ /opt/gitblit-\*\ /opt/gitblit\ \;\ \\
printf "%s\n" \#\ Remove\ unneeded\ scripts.
    printf "%s\n" \ \ \ \ rm\ -f\ /opt/gitblit/install-service-\*.sh\ \;\ \\
    printf "%s\n" \ \ \ \ rm\ -r\ /opt/gitblit/service-\*.sh\ \;\ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ It\ is\ getting\ annoying\ not\ to\ have\ \'ll\'\ and\ colors\ when\ opening\ a\ bash\ in\ the\ container
    printf "%s\n" \ \ \ \ echo\ \"export\ LS_OPTIONS=\'--color=auto\'\"\ \>\>\ /root/.bashrc\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \'eval\ \`dircolors\ -b\`\'\ \>\>\ /root/.bashrc\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"alias\ ls=\'\"\'ls\ \$LS_OPTIONS\'\"\'\"\ \>\>\ /root/.bashrc\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"alias\ ll=\'\"\'ls\ \$LS_OPTIONS\ -l\'\"\'\"\ \>\>\ /root/.bashrc\ \;
printf "\n"
fi
printf "\n"
printf "\n"
printf "\n"
printf "%s\n" LABEL\ maintainer=\"James\ Moger\ \<james.moger@gitblit.com\>\,\ Florian\ Zschocke\ \<f.zschocke+gitblit@gmail.com\>\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.schema-version=\"1.0\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.name=\"gitblit\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.description=\"Gitblit\ is\ an\ open-source\,\ pure\ Java\ stack\ for\ managing\,\ viewing\,\ and\ serving\ Git\ repositories.\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.url=\"http://gitblit.com\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.version=\"\$\{GITBLIT_VERSION\}\"
printf "\n"
printf "\n"
printf "%s\n" ENV\ GITBLIT_VAR\ "${GITBLIT_VAR}"
printf "\n"
printf "%s\n" \#\ Move\ the\ data\ files\ to\ a\ separate\ directory\ and\ set\ some\ defaults
printf "%s\n" RUN\ set\ -eux\ \;\ \\
    printf "%s\n" \ \ \ \ mkdir\ -p\ -m\ 0775\ \$GITBLIT_VAR\ \;\ \\
    printf "%s\n" \ \ \ \ gbetc=\$GITBLIT_VAR/etc\ \;\ \\
    printf "%s\n" \ \ \ \ gbsrv=\$GITBLIT_VAR/srv\ \;\ \\
    printf "%s\n" \ \ \ \ mkdir\ -p\ -m\ 0775\ \$gbsrv\ \;\ \\
    printf "%s\n" \ \ \ \ mv\ /opt/gitblit/data/git\ \$gbsrv\ \;\ \\
    printf "%s\n" \ \ \ \ ln\ -s\ \$gbsrv/git\ /opt/gitblit/data/git\ \;\ \\
    printf "%s\n" \ \ \ \ mv\ /opt/gitblit/data\ \$gbetc\ \;\ \\
    printf "%s\n" \ \ \ \ ln\ -s\ \$gbetc\ /opt/gitblit/data\ \;\ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Make\ sure\ that\ the\ most\ current\ default\ properties\ file\ is\ available
printf "%s\n" \#\ unedited\ to\ Gitblit.
    printf "%s\n" \ \ \ \ mkdir\ -p\ /opt/gitblit/etc/\ \;\ \\
    printf "%s\n" \ \ \ \ mv\ \$gbetc/defaults.properties\ /opt/gitblit/etc\ \;\ \\
    printf "%s\n" \ \ \ \ printf\ \"\\
printf "%s\n" 6\ c\\\\\\n\\
printf "%s\n" \\\\\\n\\
printf "%s\n" \\\\\\n\\
printf "%s\n" \"\"#\\\\\\n\\
printf "%s\n" \"\"#\ DO\ NOT\ EDIT\ THIS\ FILE.\ IT\ CAN\ BE\ OVERWRITTEN\ BY\ UPDATES.\\\\\\n\\
printf "%s\n" \"\"#\ FOR\ YOUR\ OWN\ CUSTOM\ SETTINGS\ USE\ THE\ FILE\ \$\{gbetc\}/gitblit.properties\\\\\\n\\
printf "%s\n" \"\"#\ THIS\ FILE\ IS\ ONLY\ FOR\ REFERENCE.\\\\\\n\\
printf "%s\n" \"\"#\\\\\\n\\
printf "%s\n" \\\\\\n\\
printf "%s\n" \\\\\\n\\
printf "%s\n" \\n\\
printf "%s\n" /\^#\ Base\ folder\ for\ repositories/\,/\^git.repositoriesFolder/d\\n\\
printf "%s\n" /\^#\ The\ location\ to\ save\ the\ filestore\ blobs/\,/\^filestore.storageFolder/d\\n\\
printf "%s\n" /\^#\ Specify\ the\ location\ of\ the\ Lucene\ Ticket\ index/\,/\^tickets.indexFolder/d\\n\\
printf "%s\n" /\^#\ The\ destination\ folder\ for\ cached\ federation\ proposals/\,/\^federation.proposalsFolder/d\\n\\
printf "%s\n" /\^#\ The\ temporary\ folder\ to\ decompress/\,/\^server.tempFolder/d\\n\\
printf "%s\n" s/\^server.httpPort.\*/#server.httpPort\ =\ 8080/\\n\\
printf "%s\n" s/\^server.httpsPort.\*/#server.httpsPort\ =\ 8443/\\n\\
printf "%s\n" s/\^server.redirectToHttpsPort.\*/#server.redirectToHttpsPort\ =\ true/\\n\\
    printf "%s\n" \ \ \ \ \"\ \>\ /tmp/defaults.sed\ \;\ \\
    printf "%s\n" \ \ \ \ sed\ -f\ /tmp/defaults.sed\ /opt/gitblit/etc/defaults.properties\ \>\ \$gbetc/defaults.properties\ \;\ \\
    printf "%s\n" \ \ \ \ rm\ -f\ /tmp/defaults.sed\ \;\ \\
printf "%s\n" \#\ \ \ Check\ that\ removal\ worked
    printf "%s\n" \ \ \ \ grep\ \ \"\^git.repositoriesFolder\"\ \$gbetc/defaults.properties\ \&\&\ false\ \;\ \\
    printf "%s\n" \ \ \ \ grep\ \ \"\^filestore.storageFolder\"\ \$gbetc/defaults.properties\ \&\&\ false\ \;\ \\
    printf "%s\n" \ \ \ \ grep\ \ \"\^tickets.indexFolder\"\ \$gbetc/defaults.properties\ \&\&\ false\ \;\ \\
    printf "%s\n" \ \ \ \ grep\ \ \"\^federation.proposalsFolder\"\ \$gbetc/defaults.properties\ \&\&\ false\ \;\ \\
    printf "%s\n" \ \ \ \ grep\ \ \"\^server.tempFolder\"\ \$gbetc/defaults.properties\ \&\&\ false\ \;\ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Create\ a\ system.properties\ file\ that\ sets\ the\ defaults\ for\ this\ docker\ setup.
printf "%s\n" \#\ This\ is\ not\ available\ outside\ and\ should\ not\ be\ changed.
    printf "%s\n" \ \ \ \ echo\ \"git.repositoriesFolder\ =\ \$\{gbsrv\}/git\"\ \>\ \ /opt/gitblit/etc/system.properties\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"filestore.storageFolder\ =\ \$\{gbsrv\}/lfs\"\ \>\>\ /opt/gitblit/etc/system.properties\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"tickets.indexFolder\ =\ \$\{gbsrv\}/tickets/lucene\"\ \>\>\ /opt/gitblit/etc/system.properties\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"federation.proposalsFolder\ =\ \$\{gbsrv\}/fedproposals\"\ \>\>\ /opt/gitblit/etc/system.properties\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"server.tempFolder\ =\ \$\{GITBLIT_VAR\}/temp/gitblit\"\ \>\>\ /opt/gitblit/etc/system.properties\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"server.httpPort\ =\ 8080\"\ \>\>\ /opt/gitblit/etc/system.properties\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"server.httpsPort\ =\ 8443\"\ \>\>\ /opt/gitblit/etc/system.properties\ \;\ \\
    printf "%s\n" \ \ \ \ echo\ \"server.redirectToHttpsPort\ =\ true\"\ \>\>\ /opt/gitblit/etc/system.properties\ \;\ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Create\ a\ properties\ file\ for\ settings\ that\ can\ be\ set\ via\ environment\ variables\ from\ docker
    printf "%s\n" \ \ \ \ printf\ \'\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \'\'#\ GITBLIT-DOCKER.PROPERTIES\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \'\'#\ This\ file\ is\ used\ by\ the\ docker\ image\ to\ store\ settings\ that\ are\ defined\\n\\
printf "%s\n" \'\'#\ via\ environment\ variables.\ The\ settings\ in\ this\ file\ are\ automatically\ changed\,\\n\\
printf "%s\n" \'\'#\ added\ or\ deleted.\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \'\'#\ Do\ not\ define\ your\ custom\ settings\ in\ this\ file.\ Your\ overrides\ or\\n\\
printf "%s\n" \'\'#\ custom\ settings\ should\ be\ defined\ in\ the\ \"gitblit.properties\"\ file.\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \'\'#\ Do\ NOT\ change\ this\ include\ line.\ It\ makes\ sure\ that\ settings\ for\ this\ docker\ image\ are\ set.\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" include\ =\ /opt/gitblit/etc/defaults.properties\,/opt/gitblit/etc/system.properties\\n\\
printf "%s\n" \\n\'\ \>\ \$gbetc/gitblit-docker.properties\ \;\ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Comment\ out\ settings\ in\ defaults\ that\ we\ support\ to\ override\ in\ gitblit-docker.properties
    printf "%s\n" \ \ \ \ sed\ -i\ -e\ \'s/\^\\\(web.enableRpcServlet.\*\\\)/#\\1/\'\ \\
           printf "%s\n" \ \ \ \ \ \ \ \ \ \ \ -e\ \'s/\^\\\(web.enableRpcManagement.\*\\\)/#\\1/\'\ \\
           printf "%s\n" \ \ \ \ \ \ \ \ \ \ \ -e\ \'s/\^\\\(web.enableRpcAdministration.\*\\\)/#\\1/\'\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ \$gbetc/defaults.properties\ \;\ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Create\ the\ gitblit.properties\ file\ that\ the\ user\ can\ use\ for\ customization.
    printf "%s\n" \ \ \ \ printf\ \'\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \'\'#\ GITBLIT.PROPERTIES\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \'\'#\ Define\ your\ custom\ settings\ in\ this\ file\ and/or\ include\ settings\ defined\ in\\n\\
printf "%s\n" \'\'#\ other\ properties\ files.\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \\n\\
printf "%s\n" \'\'#\ NOTE:\ Gitblit\ will\ not\ automatically\ reload\ \"included\"\ properties.\ \ Gitblit\\n\\
printf "%s\n" \'\'#\ only\ watches\ the\ \"gitblit.properties\"\ file\ for\ modifications.\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \'\'#\ Paths\ may\ be\ relative\ to\ the\ \$\{baseFolder\}\ or\ they\ may\ be\ absolute.\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \'\'#\ ONLY\ append\ your\ custom\ settings\ files\ at\ the\ END\ of\ the\ \"include\"\ line.\\n\\
printf "%s\n" \'\'#\ The\ present\ files\ define\ the\ default\ settings\ for\ the\ docker\ container.\ If\ you\\n\\
printf "%s\n" \'\'#\ remove\ them\ or\ change\ the\ order\,\ things\ may\ break.\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" include\ =\ gitblit-docker.properties\\n\\
printf "%s\n" \\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \'\'#\ Define\ your\ overrides\ or\ custom\ settings\ below\\n\\
printf "%s\n" \'\'#\\n\\
printf "%s\n" \\n\'\ \>\ \$gbetc/gitblit.properties\ \;\ \\
    printf "%s\n" \ \ \ \ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Change\ ownership\ to\ gitblit\ user\ for\ all\ files\ that\ the\ process\ needs\ to\ write
    printf "%s\n" \ \ \ \ chown\ -R\ gitblit:gitblit\ \$GITBLIT_VAR\ \;\ \\
printf "%s\n" \#\ Set\ file\ permissions\ so\ that\ gitblit\ can\ read\ all\ and\ others\ cannot\ mess\ up
printf "%s\n" \#\ or\ read\ private\ data
    printf "%s\n" \ \ \ \ chmod\ ug+rwxs\ \$gbsrv\ \$gbsrv/git\ \;\ \\
    printf "%s\n" \ \ \ \ chmod\ ug+rwxs\ \$gbetc\ \$gbetc/certs\ \;\ \\
    printf "%s\n" \ \ \ \ chmod\ go=r\ \$gbetc/defaults.properties\ \;\ \\
    printf "%s\n" \ \ \ \ chmod\ 0664\ \$gbetc/gitblit-docker.properties\ \;\ \\
    printf "%s\n" \ \ \ \ chmod\ 0664\ \$gbetc/gitblit.properties\ \;\ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Now\ we\ make\ a\ backup\ of\ the\ etc\ files\,\ so\ that\ we\ can\ copy\ them\ to\ mount\ bound
printf "%s\n" \#\ volumes\ to\ make\ sure\ all\ needed\ files\ are\ present\ in\ them.
    printf "%s\n" \ \ \ \ cp\ -a\ \$gbetc\ /opt/gitblit/vog-etc\ \;\ \\
    printf "%s\n" \ \ \ \ cp\ -a\ \$gbsrv/git/project.mkd\ /opt/gitblit/srv-project.mkd\ \;
printf "\n"
printf "\n"
if [[ "$DOCKERFILE_TYPE" != alpine && "$DOCKERFILE_TYPE" != ubuntu ]] ; then
printf "%s\n" \#
printf "%s\n" \#\ Create\ the\ alpine\ based\ image\,\ using\ the\ gitblit\ installation\ prepared\ in\ the\ base\ image
printf "%s\n" \#
printf "%s\n" FROM\ openjdk:8-jre-alpine\ AS\ alpine
printf "\n"
printf "%s\n" \#\ add\ our\ user\ and\ group\ first\ to\ make\ sure\ their\ IDs\ get\ assigned\ consistently\,\ regardless\ of\ whatever\ packages\ get\ added
printf "%s\n" RUN\ addgroup\ -S\ -g\ 8117\ gitblit\ \&\&\ adduser\ -S\ -H\ -G\ gitblit\ -u\ 8117\ -h\ /opt/gitblit\ gitblit
printf "\n"
printf "\n"
printf "%s\n" ENV\ GITBLIT_VERSION\ "${GITBLIT_VERSION}"
printf "%s\n" ENV\ GITBLIT_VAR\ "${GITBLIT_VAR}"
printf "\n"
printf "\n"
printf "%s\n" COPY\ --from=base\ /opt/gitblit\ /opt/gitblit
printf "%s\n" COPY\ --from=base\ \$\{GITBLIT_VAR\}\ \$\{GITBLIT_VAR\}
printf "\n"
printf "%s\n" \#\ Install\ su-exec\ to\ step\ down\ from\ root
printf "%s\n" RUN\ set\ -eux\;\ \\
    printf "%s\n" \ \ \ \ apk\ add\ --no-cache\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ \'su-exec\>=0.2\'\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ \;\ \\
    printf "%s\n" \ \ \ \ \\
    printf "%s\n" \ \ \ \ \\
printf "%s\n" \#\ Change\ shell\ to\ \'sh\'\ for\ Alpine
    printf "%s\n" \ \ \ \ for\ file\ in\ /opt/gitblit/\*.sh\ \;\ do\ \\
        printf "%s\n" \ \ \ \ \ \ \ \ sed\ -i\ -e\ \'s\;bin/bash\;bin/sh\;\'\ \$file\ \;\ \\
    printf "%s\n" \ \ \ \ done
printf "\n"
printf "\n"
printf "\n"
printf "%s\n" LABEL\ maintainer=\"James\ Moger\ \<james.moger@gitblit.com\>\,\ Florian\ Zschocke\ \<f.zschocke+gitblit@gmail.com\>\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.schema-version=\"1.0\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.name=\"gitblit\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.description=\"Gitblit\ is\ an\ open-source\,\ pure\ Java\ stack\ for\ managing\,\ viewing\,\ and\ serving\ Git\ repositories.\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.url=\"http://gitblit.com\"\ \\
      printf "%s\n" \ \ \ \ \ \ org.label-schema.version=\"\$\{GITBLIT_VERSION\}\"
printf "\n"
printf "\n"
printf "\n"
printf "%s\n" \#\ Provide\ script\ and\ data\ to\ migrate\ from\ earlier\ images\ to\ the\ new\ layout.
printf "%s\n" COPY\ migrate/migrate-data\ /usr/local/bin/
printf "%s\n" COPY\ migrate/non-etc-files\ migrate/defaults.\*\ /usr/local/share/gitblit/
printf "\n"
printf "\n"
printf "%s\n" \#\ Setup\ the\ Docker\ container\ environment
printf "%s\n" ARG\ GITBLIT_RPC
printf "%s\n" ENV\ GITBLIT_RPC\ \$\{GITBLIT_RPC:-on\}
printf "%s\n" ENV\ PATH\ /opt/gitblit:\$PATH
printf "\n"
printf "%s\n" WORKDIR\ /opt/gitblit
printf "\n"
printf "%s\n" VOLUME\ \$GITBLIT_VAR
printf "\n"
printf "\n"
printf "%s\n" COPY\ docker-entrypoint.sh\ /usr/local/bin/
printf "%s\n" ENTRYPOINT\ \[\"docker-entrypoint.sh\"\]
printf "\n"
printf "%s\n" \#\ 8080:\ \ HTTP\ front-end\ and\ transport
printf "%s\n" \#\ 8443:\ \ HTTPS\ front-end\ and\ transport
printf "%s\n" \#\ 9418:\ \ Git\ protocol\ transport
printf "%s\n" \#\ 29418:\ SSH\ transport
printf "%s\n" EXPOSE\ 8080\ 8443\ 9418\ 29418
printf "%s\n" CMD\ \[\"gitblit\"\]
printf "\n"
printf "\n"
printf "\n"
printf "\n"
printf "\n"
printf "%s\n" \#
printf "%s\n" \#\ Create\ the\ Ubuntu\ based\ image\,\ continuing\ the\ base\ image
printf "%s\n" \#
printf "%s\n" FROM\ base\ AS\ ubuntu
printf "\n"
fi
printf "\n"
printf "%s\n" \#\ Provide\ script\ and\ data\ to\ migrate\ from\ earlier\ images\ to\ the\ new\ layout.
printf "%s\n" COPY\ migrate/migrate-data\ /usr/local/bin/
printf "%s\n" COPY\ migrate/non-etc-files\ migrate/defaults.\*\ /usr/local/share/gitblit/
printf "\n"
printf "\n"
printf "%s\n" \#\ Setup\ the\ Docker\ container\ environment
printf "%s\n" ARG\ GITBLIT_RPC
printf "%s\n" ENV\ GITBLIT_RPC\ \$\{GITBLIT_RPC:-on\}
printf "%s\n" ENV\ PATH\ /opt/gitblit:\$PATH
printf "\n"
printf "%s\n" WORKDIR\ /opt/gitblit
printf "\n"
printf "%s\n" VOLUME\ \$GITBLIT_VAR
printf "\n"
printf "\n"
printf "%s\n" COPY\ docker-entrypoint.sh\ /usr/local/bin/
printf "%s\n" ENTRYPOINT\ \[\"docker-entrypoint.sh\"\]
printf "\n"
printf "%s\n" \#\ 8080:\ \ HTTP\ front-end\ and\ transport
printf "%s\n" \#\ 8443:\ \ HTTPS\ front-end\ and\ transport
printf "%s\n" \#\ 9418:\ \ Git\ protocol\ transport
printf "%s\n" \#\ 29418:\ SSH\ transport
printf "%s\n" EXPOSE\ 8080\ 8443\ 9418\ 29418
printf "%s\n" CMD\ \[\"gitblit\"\]
printf "\n"
