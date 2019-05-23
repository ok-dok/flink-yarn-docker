FROM okdokey/hadoop:2.9.2-HA

# Configure Flink version
ENV FLINK_VERSION=1.8.0 \
    HADOOP_SCALA_VARIANT=scala_2.12 \
    GPG_KEY=F2A67A8047499BBB3908D17AA8F4FD97121D7293

# Prepare environment
ENV FLINK_HOME=/opt/flink
ENV PATH=$FLINK_HOME/bin:$PATH
RUN useradd --system --home-dir $FLINK_HOME --uid=9999 --gid=hadoop -s /bin/bash -c "Flink Account" flink
COPY flink-profile.sh /etc/profile.d/

WORKDIR $FLINK_HOME

ENV FLINK_FILE_NAME=flink-${FLINK_VERSION}-bin-${HADOOP_SCALA_VARIANT}.tgz 
# Not all mirrors have the .asc files
ENV FLINK_TGZ_URL=https://www.apache.org/dist/flink/flink-${FLINK_VERSION}/${FLINK_FILE_NAME} \
    FLINK_ASC_URL=https://www.apache.org/dist/flink/flink-${FLINK_VERSION}/${FLINK_FILE_NAME}.asc
ENV SHADED_HADOOP_URL=https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop2-uber/2.8.3-${FLINK_VERSION}/flink-shaded-hadoop2-uber-2.8.3-${FLINK_VERSION}.jar

# Install flink
RUN set -ex; \
  wget -nv -O flink.tgz "$FLINK_TGZ_URL"; \
  wget -nv -O flink.tgz.asc "$FLINK_ASC_URL"; \
  \
  export GNUPGHOME="$(mktemp -d)"; \
  for server in ha.pool.sks-keyservers.net $(shuf -e \
                          hkp://p80.pool.sks-keyservers.net:80 \
                          keyserver.ubuntu.com \
                          hkp://keyserver.ubuntu.com:80 \
                          pgp.mit.edu) ; do \
      gpg --batch --keyserver "$server" --recv-keys "$GPG_KEY" && break || : ; \
  done && \
  gpg --batch --verify flink.tgz.asc flink.tgz; \
  gpgconf --kill all; \
  rm -rf "$GNUPGHOME" flink.tgz.asc; \
  \
  tar -xf flink.tgz --strip-components=1; \
  rm flink.tgz; \
  \
  chown -R flink:hadoop .;

# Copy hadoop container's sshkey, without sshkey flink cannot connect to port 8032 of yarn resourcemanager.
RUN cp -r /home/hadoop/.ssh ./; 

# Copy configuration file.
COPY flink-conf.yaml conf/

# Create a soft link of java because flink will find '/bin/java'.
# Replace slf4j-log4j12-1.7.15.jar with  slf4j-log4j12-1.7.25.jar. 
# Download the optional pre-bundled Hadoop that matches your version and place it in the lib folder of Flink
RUN ln -s $JAVA_HOME/bin/java /bin/java; \
    rm -f $FLINK_HOME/lib/slf4j-log4j12-1.7.15.jar; \
    ln -s /opt/hadoop/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar $FLINK_HOME/lib/slf4j-log4j12-1.7.25.jar; \
    wget -nv -P ${FLINK_HOME}/lib/ ${SHADED_HADOOP_URL}

# Configure container
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 6123 8081 8082
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ "bash ]