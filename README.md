# Gitblit & Docker

These instructions assume you are running Linux and you have already [installed Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/).


## Running Gitblit in Docker

You can use the official [Gitblit Docker image](https://hub.docker.com/r/gitblit/gitblit).

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

