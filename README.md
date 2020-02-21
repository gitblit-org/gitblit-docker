# Gitblit & Docker

These instructions assume you are running Linux and you have already [installed Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/).


## Running Gitblit in Docker

You can use the official [Gitblit Docker image](https://hub.docker.com/r/gitblit/gitblit).

```
sudo docker pull gitblit/gitblit
sudo docker run -d --name gitblit -p 8443:8443 -p 8080:8080 -p 9418:9418 -p 29418:29418 gitblit/gitblit
```

The followings commands should retrieve and execute the Gitblit image and launch Gitblit in a Docker container that serves the web UI on ports 8080 and 8443.  Your repositories will also be accessible via ssh, http, https, and the git procotol.  The RPC administration interface has also been enabled so that you may use the Gitblit Manager to configure settings, manage repositories, or manage users.

You should be able to browse to http://localhost:8080 or https://localhost:8443 and login as `admin/admin`.

You can stop your container with:
```
sudo docker stop gitblit
```

You can manually start your container with:
```
sudo docker start gitblit
```

## Build Instructions

Thanks to [Nicola Paolucci](https://blogs.atlassian.com/2013/11/docker-all-the-things-at-atlassian-automation-and-wiring/) at [Atlassian](https://atlassian.com) for the terrific [Stash](https://www.atlassian.com/stash) example.

### Clone this Repository
```
git clone https://github.com/gitblit/gitblit-docker.git
```
### Build your Docker container
```
cd gitblit-docker
sudo docker build -t my-gitblit - < Dockerfile
```
### Run your Gitblit container and setup localhost port-forwarding (*-p localhost:container*)
```
sudo docker run -d --name gitblit -p 8443:8443 -p 8080:8080 -p 9418:9418 -p 29418:29418 my-gitblit
```

