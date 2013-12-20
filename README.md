# Gitblit & Docker

Thanks to [Nicola Paolucci](https://blogs.atlassian.com/2013/11/docker-all-the-things-at-atlassian-automation-and-wiring/) at [Atlassian](https://atlassian.com) for the terrific [Stash](https://www.atlassian.com/stash) example.

These instructions assume you are working with Fedora 19 or 20.

## Get Docker
```
sudo yum install docker-io
```
## Clone this Repository
```
git clone https://bitbucket.org/jmoger/gitblit-docker.git
```
## Build your Docker container
```
cd gitblit-docker
sudo docker build -t jmoger/gitblit:1.3.2 .
```
## Run your Gitblit container and setup localhost port-forwarding (*-p localhost:container*)
```
sudo docker run -d -name gitblit -p 443:443 -p 80:80 -p 9418:9418 jmoger/gitblit:1.3.2
```
## Browse to http://localhost or https://localhost

You can stop your container with:

```
sudo docker stop gitblit
```

You can start your container again with:

```
sudo docker start gitblit
```


