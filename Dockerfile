# Basics
#
from openjdk:8-jre-alpine
maintainer James Moger <james.moger@gitblit.com>

# Install Gitblit
run apk add --update curl &&\
        rm -rf /var/cache/apk/* && \
	curl -Lks http://dl.bintray.com/gitblit/releases/gitblit-1.8.0.tar.gz -o /root/gitblit.tar.gz && \
	mkdir -p /opt/gitblit-tmp && \
	tar zxf /root/gitblit.tar.gz -C /opt/gitblit-tmp && \
	mv /opt/gitblit-tmp/gitblit-1.8.0 /opt/gitblit && \
	rm -rf /opt/gitblit-tmp && \
	rm -f /root/gitblit.tar.gz && \
	mkdir -p /opt/gitblit-data && \
	mv /opt/gitblit/data/* /opt/gitblit-data

# Adjust the default Gitblit settings to bind to 80, 443, 9418, 29418, and allow RPC administration.
#
# Note: we are writing to a different file here because sed doesn't like to the same file it
# is streaming.  This is why the original properties file was renamed earlier.

run echo "server.httpPort=80" >> /opt/gitblit-data/gitblit.properties && \
	echo "server.httpsPort=443" >> /opt/gitblit-data/gitblit.properties && \
	echo "server.redirectToHttpsPort=true" >> /opt/gitblit-data/gitblit.properties && \
	echo "web.enableRpcManagement=true" >> /opt/gitblit-data/gitblit.properties && \
	echo "web.enableRpcAdministration=true" >> /opt/gitblit-data/gitblit.properties

# Setup the Docker container environment and run Gitblit
workdir /opt/gitblit
expose 80
expose 443
expose 9418
expose 29418
cmd ["java", "-server", "-Xmx1024M", "-Djava.awt.headless=true", "-jar", "/opt/gitblit/gitblit.jar", "--baseFolder", "/opt/gitblit-data"]
