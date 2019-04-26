FROM openjdk:8-jre

# Setup sources
RUN set -ex; \
    echo "deb http://mirrors.163.com/debian/ stretch main non-free contrib\
          deb http://mirrors.163.com/debian/ stretch-updates main non-free contrib\
          deb http://mirrors.163.com/debian/ stretch-backports main non-free contrib\
          deb-src http://mirrors.163.com/debian/ stretch main non-free contrib\
          deb-src http://mirrors.163.com/debian/ stretch-updates main non-free contrib\
          deb-src http://mirrors.163.com/debian/ stretch-backports main non-free contrib\
          deb http://mirrors.163.com/debian-security/ stretch/updates main non-free contrib\
          deb-src http://mirrors.163.com/debian-security/ stretch/updates main non-free contrib" > /etc/apt/sources.list; \
    apt-get update

# Install dependencies
RUN set -ex; \
    apt-get -y install apt-utils; \
    apt-get -y install libsnappy1v5; \
    rm -rf /var/lib/apt/lists/*

# Grab gosu for easy step-down from root
ENV GOSU_VERSION 1.11
RUN set -ex; \
  wget -nv -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)"; \
  wget -nv -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc"; \
  export GNUPGHOME="$(mktemp -d)"; \
  for server in ha.pool.sks-keyservers.net $(shuf -e \
                          hkp://p80.pool.sks-keyservers.net:80 \
                          keyserver.ubuntu.com \
                          hkp://keyserver.ubuntu.com:80 \
                          pgp.mit.edu) ; do \
      gpg --batch --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
  done && \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  gpgconf --kill all; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  chmod +x /usr/local/bin/gosu; \
  gosu nobody true

# Install sshd
RUN apt-get update; \
    apt-get -y install openssh-server openssh-client 

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key; \
    echo y | ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key; \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa; \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys; \
    chmod -R 700 /root/.ssh;

# Configure Hadoop version
ENV HADOOP_VERSION 3.2.0

# Prepare environment
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_HOME $HADOOP_HOME/etc/hadoop
ENV PATH $HADOOP_HOME/bin:$HOADOOP_HOME/sbin:$PATH
RUN groupadd --system --gid=9999 hadoop && \
    useradd --system -m --uid=9998 --gid=hadoop -s /bin/bash -c "Hadoop Account" hadoop
WORKDIR $HADOOP_HOME

ENV HADOOP_FILE_URL http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
ENV HADOOP_ASC_URL https://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.asc
ENV HADOOP_KEYS_URL https://www.apache.org/dist/hadoop/common/KEYS

# Download Hadoop
RUN set -ex; \
    wget -nv -O hadoop.tar.gz "$HADOOP_FILE_URL"; \
    wget -nv -O hadoop.tar.gz.asc "$HADOOP_ASC_URL"; \
    wget -nv -O KEYS "$HADOOP_KEYS_URL";

# Verify and install Hadoop
RUN gpg --import KEYS; \
    gpg --verify hadoop.tar.gz.asc hadoop.tar.gz; \
    rm -rf KEYS hadoop.tar.gz.asc; \
    \
    tar -zxf hadoop.tar.gz --strip-components=1; \
    rm hadoop.tar.gz; \
    \
    chown -R hadoop:hadoop .; 

# Copy configuration files
COPY core-site.xml  ${HADOOP_CONF_HOME}/
COPY hdfs-site.xml  ${HADOOP_CONF_HOME}/
COPY yarn-site.xml  ${HADOOP_CONF_HOME}/ 
COPY mapred-site.xml ${HADOOP_CONF_HOME}/

# Set JAVA_HOME environment
RUN echo JAVA_HOME=${JAVA_HOME} >> ${HADOOP_CONF_HOME}/hadoop-env.sh

# Generate ssh rsa key
WORKDIR /home/hadoop
RUN mkdir -p tmp hdfs/name hdfs/data .ssh; \
    ssh-keygen -q -N "" -t rsa -f .ssh/id_rsa; \
    cp .ssh/id_rsa.pub .ssh/authorized_keys; \
    chown -R hadoop:hadoop .; \
    chmod -R 700 .ssh;

# Configure container
COPY --chown=root:root docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

EXPOSE 22

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "-d"]