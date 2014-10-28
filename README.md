# Gitblit & Docker

These instructions assume you are running Ubuntu and you have already installed Docker.

```
sudo apt-get install docker.io
```

## Running Gitblit in Docker

You can use the Gitblit Docker image I have created [here](https://registry.hub.docker.com/u/jmoger/gitblit).

```
sudo docker.io pull jmoger/gitblit
<wait a while>
sudo docker.io run -d -name gitblit -p 443:443 -p 80:80 -p 9418:9418 -p 29418:29418 jmoger/gitblit
```

The followings commands should retrieve and execute the Gitblit image and launch Gitblit in a Docker container that serves the web ui on ports 80 and 443.  Your repositories will also be accessible via ssh, http, https, and the git procotol.  The RPC administration interface has also been enabled so that you may use the Gitblit Manager to configure settings, manage repositories, or manage users.

You should be able to browse to http://localhost or https://localhost and login as `admin/admin`.

You can stop your container with:
```
sudo docker.io stop gitblit
```

You can manually start your container with:
```
sudo docker.io start gitblit
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
sudo docker.io build -t jmoger/gitblit:1.6.2 .
```
### Run your Gitblit container and setup localhost port-forwarding (*-p localhost:container*)
```
sudo docker.io run -d --name gitblit -p 443:443 -p 80:80 -p 9418:9418 -p 29418:29418 jmoger/gitblit:1.6.2
```

