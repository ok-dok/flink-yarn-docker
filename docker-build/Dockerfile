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

ARG FLINK_FILE_NAME=flink-${FLINK_VERSION}-bin-${HADOOP_SCALA_VARIANT}.tgz 
ARG FLINK_FILE_URL_DEFAULT=https://www.apache.org/dist/flink/flink-${FLINK_VERSION}/${FLINK_FILE_NAME}
ARG FLINK_FILE_URL_TSINGHUA=http://mirrors.tuna.tsinghua.edu.cn/apache/flink/flink-${FLINK_VERSION}/${FLINK_FILE_NAME}
ARG FLINK_FILE_URL_BIT=http://mirror.bit.edu.cn/apache/flink/flink-${FLINK_VERSION}/${FLINK_FILE_NAME}
ARG FLINK_FILE_URL_EU=https://www-eu.apache.org/dist/flink/flink-${FLINK_VERSION}/${FLINK_FILE_NAME}
ARG FLINK_FILE_URL_US=https://www-us.apache.org/dist/flink/flink-${FLINK_VERSION}/${FLINK_FILE_NAME}
# Not all mirrors have the .asc files
ARG FLINK_ASC_URL=https://www.apache.org/dist/flink/flink-${FLINK_VERSION}/${FLINK_FILE_NAME}.asc
ARG SHADED_HADOOP_URL=https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop2-uber/2.8.3-${FLINK_VERSION}/flink-shaded-hadoop2-uber-2.8.3-${FLINK_VERSION}.jar

# Download flink
RUN set -ex; \
  axel -qkn 20 -o flink.tgz "${FLINK_FILE_URL_TSINGHUA}" "${FLINK_FILE_URL_BIT}" "${FLINK_FILE_URL_DEFAULT}" "${FLINK_FILE_URL_EU}" "${FLINK_FILE_URL_US}";

# Verify & Install flink
RUN axel -qkn 4 -o flink.tgz.asc "$FLINK_ASC_URL"; \
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
  tar -xf flink.tgz --strip-components=1; \
  rm flink.tgz;

RUN axel -qkn 10 -o lib ${SHADED_HADOOP_URL}; \
  chown -R flink:hadoop .;

# Create a soft link of java because flink will find '/bin/java'.
# Replace slf4j-log4j12-1.7.15.jar with  slf4j-log4j12-1.7.25.jar. 
# Download the optional pre-bundled Hadoop that matches your version and place it in the lib folder of Flink
RUN ln -s $JAVA_HOME/bin/java /bin/java; \
    rm -f ./lib/slf4j-log4j12-1.7.15.jar; \
    ln -s /opt/hadoop/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar ./lib/slf4j-log4j12-1.7.25.jar;


# Copy hadoop container's sshkey, without sshkey flink cannot connect to port 8032 of yarn resourcemanager.
RUN cp -r /home/hadoop/.ssh ./; 

# Copy configuration file.
COPY flink-conf.yaml conf/

RUN chown -R flink:hadoop .;

# Configure container
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 6123 8081 8082
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ "/bin/bash" ]