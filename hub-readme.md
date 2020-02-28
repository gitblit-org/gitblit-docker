# What is Gitblit?

Gitblit is an open-source, pure Java stack for managing, viewing, and serving Git repositories.
It's designed primarily as a tool for small to medium workgroups who want to host centralized repositories.

Gitblit can be used as a dumb repository viewer with no administrative controls or user accounts.
Gitblit can be used as a complete Git stack for cloning, pushing, and repository access control.
Gitblit can be used without any other Git tooling or it can cooperate with your established tools.

[https://gitblit.com](https://gitblit.com)

![logo](https://github.com/gitblit/gitblit/raw/v1.9.0/src/main/resources/gitblt2.png)



# How to use this image

You can simply start serving git repositories by running a container from a provided image.

```console
sudo docker pull gitblit/gitblit:rpc
sudo docker run -d --name gitblit -p 8443:8443 -p 8080:8080 -p 9418:9418 -p 29418:29418 gitblit/gitblit:rpc
```

This will launch Gitblit serving the web UI on ports 8080 (HTTP) and 8443 (HTTPS).  Your repositories will also be accessible via SSH (29418), HTTP, HTTPS, and the GIT (9418) procotol.  The RPC administration interface has been enabled for the `*-rpc`images so that you may use the Gitblit Manager to configure settings, manage repositories, or manage users.

Browse to http://localhost:8080 or https://localhost:8443 and login as `admin/admin`.

You can select which transports you want to make available from the container. For example, if you only want to use HTTPS and SSH, run:

```console
sudo docker run -d --name gitblit -p 8443:8443 -p 29418:29418 gitblit/gitblit:rpc
```

### Stop the container

Gitblit can be shut down cleanly with the `gitblit-stop.h` script.

```console
sudo docker exec -it gitblit gitblit-stop.sh
```

You can also stop the container with a normal stop command.

```console
sudo docker stop gitblit
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

