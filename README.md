# Gitblit & Docker

## Running Gitblit in Docker

You can use the Gitblit Docker image I have created [here](https://index.docker.io/u/jmoger/gitblit).

```
sudo docker pull jmoger/gitblit
<wait a while>
sudo docker run -d -name gitblit -p 443:443 -p 80:80 -p 9418:9418 jmoger/gitblit
```

The followings commands should retrieve and execute the Gitblit image and launch Gitblit in a Docker container that serves the web ui on ports 80 and 443.  Your repositories will also be accessible via http, https, and the git procotol.  The RPC administration interface has also been enabled so that you may use the Gitblit Manager to configure settings, manage repositories, or manage users.

You should be able to browse to http://localhost or https://localhost and login as `admin/admin`.

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

These instructions assume you are working with Fedora 19 or 20.

### Get Docker
```
sudo yum install docker-io
```
### Clone this Repository
```
git clone https://bitbucket.org/jmoger/gitblit-docker.git
```
### Build your Docker container
```
cd gitblit-docker
sudo docker build -t jmoger/gitblit:1.3.2 .
```
### Run your Gitblit container and setup localhost port-forwarding (*-p localhost:container*)
```
sudo docker run -d -name gitblit -p 443:443 -p 80:80 -p 9418:9418 jmoger/gitblit:1.3.2
```

