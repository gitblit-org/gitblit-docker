# Gitblit & Docker

These instructions assume you are running Linux and you have already [installed Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/).


## Running Gitblit in Docker

You can use the official [Gitblit Docker image](https://hub.docker.com/r/gitblit/gitblit).

See the [Docker Hub Readme](hub-readme.md) for more detailed usage information.


### Start a Gitblit instance


```
sudo docker pull gitblit/gitblit:rpc
sudo docker run -d --name gitblit -p 8443:8443 -p 8080:8080 -p 9418:9418 -p 29418:29418 gitblit/gitblit:rpc
```

The followings commands should retrieve and execute the Gitblit image and launch Gitblit in a Docker container that serves the web UI on ports 8080 and 8443.  Your repositories will also be accessible via ssh, http, https, and the git procotol.  The RPC administration interface has also been enabled so that you may use the Gitblit Manager to configure settings, manage repositories, or manage users.

You should be able to browse to http://localhost:8080 or https://localhost:8443 and login as `admin/admin`.


### Stop the instance

You can shutdown your gitblit container with:
```
sudo docker exec -it gitblit gitblit-stop.sh
```

You can manually re-start your container with:
```
sudo docker start gitblit
```


### Data persistence

The Gitblit image stores data under `/var/opt/gitblit`. A Docker volume is defined for this path,
so that data is stored persistently and efficiently. The data is split into a subfolder for
configuration data (`etc/`) and one for repository data (`srv/`).

### User id

The gitblit server is run under the user and group id `8117`, assigned to the user `gitblit`.


## Build Instructions

You can build your own Gitblit image with the files in this repository. 

### Clone this Repository
```
git clone https://github.com/gitblit/gitblit-docker.git
```

### Build your Docker container
```
cd gitblit-docker
sudo docker build -t my-gitblit .
```

### Run your Gitblit container and setup localhost port-forwarding (*-p localhost:container*)
```
sudo docker run -d --name gitblit -p 8443:8443 -p 8080:8080 -p 9418:9418 -p 29418:29418 my-gitblit
```


## Migrating from an older image

The directory layout for the Gitblit data was changed with the image for version 1.9.0. If you had previously used a Docker image of Gitblit with a volume mounted on `/opt/gitblit-data`, migration of the configuration data is advised. A script `migrate-data` is available in the new image for this. Run the script from a container with your volume mounted under `/var/opt/gitblit`.

```console
$ ls -l
total 0
drwxr-xr-x  6 beowulf  staff       192 Mar 10 21:02 gitblit-data/

$ sudo docker run -it --rm -v $PWD/gitblit-data:/var/opt/gitblit my-gitblit migrate-data

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

$ sudo docker run -d --name gitblit -v $PWD/gitblit-data:/var/opt/gitblit -p 8080:8080 my-gitblit
```
