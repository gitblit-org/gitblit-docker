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
sudo docker pull gitblit/gitblit:rpc
sudo docker run -d --name gitblit -p 8443:8443 -p 8080:8080 -p 9418:9418 -p 29418:29418 gitblit/gitblit:rpc
```

This will launch Gitblit serving the web UI on ports 8080 (HTTP) and 8443 (HTTPS). Your repositories will
also be accessible via SSH (29418), HTTP, HTTPS, and the GIT (9418) procotol. A container is started with
the name `gitblit` using the provided image `gitblit/gitblit:rpc`.  
The RPC administration interface has been enabled for the `*-rpc`images so that you may use the Gitblit Manager
to configure settings, manage repositories, or manage users.

Browse to http://localhost:8080 or https://localhost:8443 and login as `admin` with password `admin`.

The default Gitblit Docker images define all transports used by Gitblit, but that does not mean, that they are
available from oustside the container. To make a port available to the outside world, use the `-p` commandline
parameter. For example, if you only want to use HTTPS and SSH, run:

```console
$ sudo docker run -d --name gitblit -p 8443:8443 -p 29418:29418 gitblit/gitblit:rpc
```


## Stop the instance

Gitblit can be shut down cleanly with the `gitblit-stop.h` script.

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
Gitblit for and is written often (unless you use Gitblit only as a repository browser). The docker image
uses `/var/opt/gitblit` as the base folder for data storage.

To make this data persistent and operation on it more performant, a Docker [volume](https://docs.docker.com/engine/reference/builder/#volume)
is defined for this path. [Docker manages this volume](https://docs.docker.com/storage/volumes/) automatically
for you. This is the default and the easiest configuration. The only downside is that the files may be hard to
locate for you or tools running outside the container. You can make it a little easier by defining a name for
the volume, when creating the container.

```console
$ sudo docker run -d --name gitblit -v gitblit-data:/var/opt/gitblit -p 8443:8443 -p 29418:29418 gitblit/gitblit:rpc
```

Under the base directory, configuration and repository data are separated into two different directories.
Configuration data is under `/var/opt/gitblit/etc` and repository data under `/var/opt/gitblit/srv`. If, for
some reason, you want to use different volumes for either, e.g. for different kinds of backup, you can attach
two volumes to these directories.

```console
$ sudo docker run -d --name gitblit -v gitblit-config:/var/opt/gitblit/etc -v gitblit-repos:/var/opt/gitblit/srv -p 8443:8443 -p 29418:29418 gitblit/gitblit:rpc
```

Naming a volume makes it more discoverable with [Docker's tools](https://docs.docker.com/engine/reference/commandline/volume_ls/):

```console
$ sudo docker volume ls --format 'table {{.Name}}\t{{.Mountpoint}}\t{{.Driver}}'
VOLUME NAME     MOUNTPOINT                                     DRIVER
gitblit-config  /var/lib/docker/volumes/gitblit-config/_data   local
gitblit-repos   /var/lib/docker/volumes/gitblit-repos/_data    local
```


### Temporary webapp data

For advanced usage under Linux, you may be able to improve performance by moving Gitblit's `temp` folder
to RAM. Gitblit unpacks web application data on each start into a temporary folder. The default for that
folder in the Docker image is `/var/opt/gitblit/temp`. Under Linux, you can [mount a `tmpfs` volume](https://docs.docker.com/storage/tmpfs/)
to that path which will result in the temporary files being stored in the host memory. This makes reading
fast and when the container is stopped, they are gone.

```console
$ sudo docker run -d --name gitblit --tmpfs /var/opt/gitblit/temp -p 8443:8443 gitblit/gitblit:rpc
```



# Image Variants
The `gitblit/gitblit` images come in multiple flavors, each designed for a specific use case.

## `gitblit/gitblit:<version>-rpc`

This is the defacto image. It has RPC management and administration enabled. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container, as well as the base to build other images off of.

## `httpd:<version>-rpc-alpine`

This image is based on the popular [Alpine Linux project](http://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

It has RPC management and administration enabled.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](http://www.musl-libc.org) instead of [glibc and friends](http://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as `git` or `bash`) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [`alpine` image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).

# License

View [license information](https://raw.githubusercontent.com/gitblit/gitblit/master/LICENSE) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

