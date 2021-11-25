# What is Gitblit?

Gitblit is an open-source, pure Java stack for managing, viewing, and serving Git repositories.
It's designed primarily as a tool for small to medium workgroups who want to host centralized repositories.

Gitblit can be used as a dumb repository viewer with no administrative controls or user accounts.
Gitblit can be used as a complete Git stack for cloning, pushing, and repository access control.
Gitblit can be used without any other Git tooling or it can cooperate with your established tools.

[https://gitblit.com](https://gitblit.com)

![logo](https://github.com/gitblit/gitblit/raw/v1.9.0/src/main/resources/gitblt2.png)



# How to use this image

## Start a Gitblit instance

You can simply start serving git repositories by running a container from a provided image.

```console
$ sudo docker pull gitblit/gitblit:rpc
$ sudo docker run -d --name gitblit -p 8443:8443 -p 8080:8080 -p 9418:9418 -p 29418:29418 gitblit/gitblit
```

This will launch Gitblit serving the web UI on ports 8080 (HTTP) and 8443 (HTTPS). Your repositories will
also be accessible via SSH (29418), HTTP, HTTPS, and the GIT (9418) procotol. A container is started with
the name `gitblit` using the provided image `gitblit/gitblit`.  

Browse to http://localhost:8080 or https://localhost:8443 and login as `admin` with password `admin`.

##### Ports

The default Gitblit Docker images expose all transports used by Gitblit, but that does not mean, that they are
available from outside the container. To make a port available to the outside world, use the `-p` commandline
parameter. For example, if you only want to use HTTPS and SSH, run:

```console
$ sudo docker run -d --name gitblit -p 8443:8443 -p 29418:29418 gitblit/gitblit
```

Exposed ports are:

* `8080`: HTTP
* `8443`: HTTPS
* `9418`: Git protocol
* `29418`: SSH

## Stop the instance

Gitblit can be shut down cleanly with the `gitblit-stop.sh` script.

```console
$ sudo docker exec -it gitblit gitblit-stop.sh
```

You can also stop the container with the Docker stop command.

```console
$ sudo docker stop gitblit
```


## Gitblit data storage

Gitblit stores two types of data, configuration data and Git repository data. While configuration data is
relatively static, once the server is configured and has started, the repository data is what you use
Gitblit for and is written often (unless you use Gitblit only as a repository browser). 

The docker image uses `/var/opt/gitblit` as the base folder for data storage. Under the base folder, configuration and repository data are separated into two different directories. Configuration data is under `/var/opt/gitblit/etc` and repository data under `/var/opt/gitblit/srv`. 

```console
$ docker run -it --rm gitblit/gitblit ls -l /var/opt/gitblit
total 8
drwsrws--- 5 gitblit gitblit 4096 Mar  8 16:39 etc
drwsrws--- 3 gitblit gitblit 4096 Mar  8 16:39 srv
```

To make this data persistent and operation on it more performant, a Docker [volume](https://docs.docker.com/engine/reference/builder/#volume)
is defined for the path `/var/opt/gitblit` for the image. 


Important note: There are several ways to store data used by applications that run in Docker containers. We encourage users of the gitblit images to familiarize themselves with the options available, including:

* Let Docker manage the storage of your server data [by writing the files to disk on the host system using its own internal volume management](https://docs.docker.com/get-started/05_persisting_data/#container-volumes). This is the default and is easy and fairly transparent to the user. The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.
* Create a data directory on the host system (outside the container) and [mount this to a directory visible from inside the container](https://docs.docker.com/get-started/06_bind_mounts/). This places the server files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists, and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area.

#### Data volumes
[Docker manages this volume](https://docs.docker.com/storage/volumes/) automatically
for you. This is the default and the easiest configuration. You can make the volume files a little easier to locate by defining a name for the volume, when creating the container (or, even, when creating a volume beforehand).

```console
$ sudo docker run -d --name gitblit -v gitblit-data:/var/opt/gitblit -p 8443:8443 -p 29418:29418 gitblit/gitblit
```

If, for some reason, you want to use different volumes for `etc` and `srv`, e.g. for different kinds of backup, you can attach two different volumes to these directories.

```console
$ sudo docker run -d --name gitblit -v gitblit-config:/var/opt/gitblit/etc \
                                    -v gitblit-repos:/var/opt/gitblit/srv \
                                    -p 8443:8443 -p 29418:29418 gitblit/gitblit
```

Giving a volume a name also makes it more discoverable with [Docker's tools](https://docs.docker.com/engine/reference/commandline/volume_ls/):

```console
$ sudo docker volume ls --format 'table {{.Name}}\t{{.Mountpoint}}\t{{.Driver}}'
VOLUME NAME     MOUNTPOINT                                     DRIVER
gitblit-config  /var/lib/docker/volumes/gitblit-config/_data   local
gitblit-repos   /var/lib/docker/volumes/gitblit-repos/_data    local
```

It also makes upgrades of Gitblit easier. Simply provide the same named volume to the new version of the container:

```console
$ sudo docker pull gitblit/gitblit:rpc
$ sudo docker stop gitblit
$ sudo docker container rm gitblit
$ sudo docker run -d --name gitblit -v gitblit-data:/var/opt/gitblit -p 8443:8443 -p 29418:29418 gitblit/gitblit:rpc
```

Updating with anonymous volumes (no name provided for it) requires you to either find out the volume id from the current running container and reusing that id for the new container, or to use the `--volumes-from` parameter, which requires the old container to still be around.

#### Mount bind directories

The second option is to mount a local directory on the host into the container via a [bind mount](https://docs.docker.com/storage/bind-mounts/). Again, you can choose if you want all of the data in the host directory, or maybe just the configuration data, for easier editing, while the git data is stored in a docker data volume. (Or, vice versa, of course. Or, something completely different.)

The container will copy the necessary configuration files, that Gitblit needs to run, into the directory. (While this is done automatically by docker for data volumes, it has to be done explicitly by the container for a bind mount volume.) Existing data is not overwritten (except for the `defaults.properties`file, use this only for reference). The start script will also change ownership of the directory and files to the `gitblit`user because the server process will need to be able to read them and write to some.

```console
$ sudo docker run -d --name gitblit -v /some/path/data:/var/opt/gitblit -p 8443:8443 gitblit/gitblit
```

Or, when only storing the configuration data in a local host directory, e.g. `/etc/gitblit`:

```console
$ sudo docker run -d --name gitblit -v /etc/gitblit:/var/opt/gitblit/etc -p 29418:29418 gitblit/gitblit
```

#### Temporary webapp data

For advanced usage under Linux, you may be able to improve performance by moving Gitblit's `temp` folder
to RAM. Gitblit unpacks web application data on each start into a temporary folder. The default for that
folder in the Docker image is `/var/opt/gitblit/temp`. Under Linux, you can [mount a `tmpfs` volume](https://docs.docker.com/storage/tmpfs/)
to that path which will result in the temporary files being stored in the host memory. This makes reading
fast and when the container is stopped, they are gone.

```console
$ sudo docker run -d --name gitblit --tmpfs /var/opt/gitblit/temp -p 8443:8443 gitblit/gitblit:rpc
```


## Running as non-root with `--user`

The gitblit images will drop root privileges in the start up script and run the Gitblit server process under the unprivileged user `gitblit` with user and group id `8117`. Still, the image allows to directly start a container as a non-root user with the `--user` command line parameter, albeit with some restrictions.

If you simply don't want any part to run with root privileges, you can directly start the container as the user `8117`:

```console
$ sudo docker run -d --name gitblit --user 8117:8117 -p 8443:8443 -p 29418:29418 gitblit/gitblit
```

What does not work, is to use a different user id. This is because that user id will not have the permissions to write to the files and directories in the container. If you want to run the container as an arbitrary user, you need to provide a bind mount volume and make sure that the ownership and permissions allow the server process to write files. For example, to run under the user `picard`:

```console
$ ls -ls
total88
drwxr-x---  2 picard  picard     64 Mar  8 18:07 gitblit-data
-rwxr-xr-x  2 picard  picard     88 Mar  8 18:07 somefile

$ sudo docker run -d -v $PWD/gitblit-data:/var/opt/gitblit --user $(id -u picard) -p 8443:8443 gitblit/gitblit
```

Another use case is, if you want to use Gitblit only as an attractive repository browser for your local git projects. In that case you can bind mount only your directory with your git projects to `/var/opt/gitblit/srv/git` and run gitblit under your user id. In this case you also need to run it under the gitblit *group* id `8117`, so that the process has access to the other data volumes containing the configuration data.

```console
$ ls -l
total 0
drwxr-xr-x  29 anthony  staff  928 Feb 28 20:00 gitblit/
drwxr-xr-x  10 anthony  staff  320 Mar  8 18:16 gitblit-docker/
drwxr-xr-x  12 anthony  staff  384 Feb 16 15:26 gitblit-maven/
drwxr-xr-x  13 anthony  staff  416 Feb 16 15:36 ok.sh/

$ sudo docker run --rm --user $(id -u):8117 -v $PWD:/var/opt/gitblit/srv/git -p 8080:8080 gitblit/gitblit --httpsPort=0
```

You can then direct your browser to [http://localhost:8080](http://localhost:8080) and directly start browsing your repositories.


## Configuration

Configure the gitblit instance by adding your custom settings to the file `gitblit.properties` in the directory `/var/opt/gitblit/etc` in the container. Some options can be controlled by providing environment variables to the container.

### Environment variables

##### RPC `GITBLIT_RPC`

Gitblit provides a [RPC interface](http://gitblit.github.io/gitblit/rpc.html) allowing a remote client to manage or administer the Gitblit server. If administration via RPC is enabled, a remote client (like the example Gitblit Manager) can be used to customize Gitblit settings. The default is to have [basic RPC enabled](http://gitblit.github.io/gitblit/rpc.html#H8) to retrieve repositories, branches, basic settings, etc. but not allow management. The `GITBLIT_RPC` environment variable can be used to control the level of RPC functionality.

* `off`: RPC is completly disabled.
* `on`: sets `web.enableRpcServlet`to true, enables retrieving information (default).
* `mgmt`: sets `web.enableRpcManagement`to true, enables management of repositories and users.
* `admin`: sets `web.enableRpcAdministration` to true, enables server administration.

For example, to turn RPC off, use:

```console
$ sudo docker run -d --name gitblit -e "GITBLIT_RPC=off"  -p 8443:8443 gitblit/gitblit
```


##### JVM options `JAVA_OPTS`

The gitblit server starts by default with the JVM option `-Xmx1024M`. You can override this by providing the `JAVA_OPTS` environment variable.

```console
$ sudo docker run -d --name gitblit -e "JAVA_OPTS=-Xmx2048m"  -p 8443:8443 gitblit/gitblit
```




## User and group id

Since image version 1.9.0-3 the gitblit process will be started as a non privileged user. The user id and group id used by the images are both `8117`.

```console
$ docker run -it --rm gitblit id gitblit
uid=8117(gitblit) gid=8117(gitblit) groups=8117(gitblit)
```


# Caveats

## Migrating from an older image version

The directory layout for the Gitblit data was changed in the official `gitblit/gitblit` image for version 1.9.0. If you had previously used a Docker image of Gitblit with a volume mounted on `/opt/gitblit-data`, migration of the configuration data is advised. This will make updates easier in the future. A script `migrate-data` is available in the current image for this. Run the script from a container with your volume mounted under `/var/opt/gitblit`.

Below is an example for a container that had the local directory `gitblit-data` as a bind mount.


```console
$ sudo docker pull gitblit/gitblit

$ sudo docker stop gitblit

$ ls -l
total 0
drwxr-xr-x  6 beowulf  staff       192 Mar 10 21:02 gitblit-data/

$ sudo docker run -it --rm -v $PWD/gitblit-data:/var/opt/gitblit gitblit/gitblit migrate-data

Creating new directories 'etc' and 'srv' ...
Moving existing files to new directories ...
   Moving to folder 'etc': certs
   Moving to folder 'etc': defaults.properties
   Moving to folder 'srv': git
   Moving to folder 'etc': gitblit.properties
   Moving to folder 'etc': gitignore
   Moving to folder 'etc': groovy
   Moving to folder 'srv': lfs
   Moving to folder 'etc': plugins
   Moving to folder 'etc': projects.conf
   Moving to folder 'etc': serverKeyStore.jks
   Moving to folder 'etc': serverTrustStore.jks
   Moving to folder 'etc': ssh-dsa-hostkey.pem
   Moving to folder 'etc': ssh-rsa-hostkey.pem
   Moving to folder 'etc': users.conf
Adjusting 'include' setting in etc/gitblit.properties
Checking the defaults.properties file for changes.
   There were changes detected in the defaults.properties file.
   These have been copied over into the gitblit.properties file.
   Please review these and adjust as required.
   The defaults.properties file should not be changed as it gets overwritten upon upgrade.
Done.

$ sudo docker run -d --name gitblit -v $PWD/gitblit-data:/var/opt/gitblit -p 8080:8080 giblit/gitblit
```

Cou could, alternatively, also run a container with the existing data directory without migration. Be advised, that in this case you will need to make sure that you have paths for temp and git folders in your `gitblit.properties` file. Also, **do not** have any custom settings in the `defaults.properties` file as this file will get **overwritten**.  
Mount your not migrated volume under `/var/opt/gitblit/etc` which is the default for the `baseFolder`, or provide the path to where you mount the volume to the container in the `--baseFolder` parameter when running the container.

```console
$ sudo docker run -v /some/path/data:/opt/gitblit-data gitblit/gitblit --baseFolder /opt/gitblit-data
```



# Image Variants
The `gitblit/gitblit` images come in multiple flavors.

## `gitblit/gitblit:latest`

This is the current release and as such the same as `gitblit/gitblit:<version>`.


## `gitblit/gitblit:nightly`

This image represents the latest development snapshot. It is build nightly from the head of the development branch when there were new commits. You can use this image to try out the current development state of Gitblit.


## `gitblit/gitblit:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container, as well as the base to build other images off of.

## `gitblit/gitblit:<version>-alpine`

This image is based on the popular [Alpine Linux project](http://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](http://www.musl-libc.org) instead of [glibc and friends](http://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as `git` or `bash`) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [`alpine` image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).


## `gitblit/gitblit:<version>-rpc`

This image has RPC management and administration already enabled, so that you may use a remote client like the Gitblit Manager to configure settings, manage repositories, or manage users.

Do *not* use the HTTP port over a network on this image for RPC, because passwords are insecurely transmitted from your browser/RPC client using Basic authentication!

## `gitblit/gitblit:<version>-rpc-alpine`

This image is based on the popular [Alpine Linux project](http://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

It has RPC management and administration already enabled, so that you may use a remote client like the Gitblit Manager to configure settings, manage repositories, or manage users.

Do *not* use the HTTP port over a network on this image for RPC, because passwords are insecurely transmitted from your browser/RPC client using Basic authentication!




# License

View [license information](https://raw.githubusercontent.com/gitblit/gitblit/master/LICENSE) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

