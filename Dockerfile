FROM ubuntu:18.04

RUN apt-get update 
RUN apt-get install -y software-properties-common xmlstarlet augeas-tools curl

# Based on webupd8team
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get install -y oracle-java8-installer
RUN echo 'export JAVAHOME=/usr/lib/jvm/java-8-oracle' >> ~/.bashrc
RUN echo 'export PATH=/usr/lib/jvm/java-8-oracle/bin:$PATH' >> ~/.bashrc

# Based on https://github.com/jboss-dockerfiles/base/blob/master/Dockerfile
WORKDIR /opt/jboss
RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss

# Based on https://github.com/jboss-dockerfiles/wildfly/blob/922cbfbd7f4fb9c2f7eb78f5ae01eb9ae83a3287/Dockerfile
ENV WILDFLY_VERSION 10.1.0.Final
ENV WILDFLY_SHA1 9ee3c0255e2e6007d502223916cefad2a1a5e333
ENV JBOSS_HOME /opt/jboss/wildfly
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}
ENV LAUNCH_JBOSS_IN_BACKGROUND true


# Based on https://bitbucket.org/opencds/apelon4-docker/raw/c57984e505905da9194a6fc89d91b99a214f86fb/Dockerfile
ENV DTS_HOME /tmp/dts
WORKDIR ${DTS_HOME}
RUN wget http://www.apelondts.org/Portals/0/Downloads/DTS%204.6.1/dts-linux_4.6.1-838.tar.gz
RUN tar xzvpf dts-linux_4.6.1-838.tar.gz
RUN cp server/wildfly-10/standalone/configuration/standalone-apelondts.xml ${JBOSS_HOME}/standalone/configuration/standalone-apelondts.xml

# DEV
RUN apt-get install -y vim

# BOOT
WORKDIR ${JBOSS_HOME}

#USER jboss
USER root
EXPOSE 8080
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-c", "${JBOSS_HOME}/standalone/configuration/standalone-apelondts.xml"]

