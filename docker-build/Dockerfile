###############################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

FROM hadoop:2.9.2-HA

# Configure Flink version
ENV FLINK_VERSION=1.8.0 \
    HADOOP_SCALA_VARIANT=scala_2.12 \
    GPG_KEY=F2A67A8047499BBB3908D17AA8F4FD97121D7293

# Prepare environment
ENV FLINK_HOME=/opt/flink
ENV PATH=$FLINK_HOME/bin:$PATH
COPY flink-env.sh /etc/profile.d/

RUN useradd --system --home-dir $FLINK_HOME --uid=9999 --gid=hadoop  -s /bin/bash -c "Flink Account" flink

ENV SHADED_HADOOP_URL=https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop2-uber/2.8.3-1.8.0/flink-shaded-hadoop2-uber-2.8.3-1.8.0.jar

ADD flink-1.8.0.tar.gz /opt/

RUN mv /opt/flink-1.8.0 /opt/flink; \
    cp -r /home/hadoop/.ssh /opt/flink/; \
    chown -R flink:hadoop /opt/flink

COPY flink-conf.yaml /opt/flink/conf/

RUN ln -s $JAVA_HOME/bin/java /bin/java; \
    rm -f $FLINK_HOME/lib/slf4j-log4j12-1.7.15.jar; \
    ln -s /opt/hadoop/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar $FLINK_HOME/lib/slf4j-log4j12-1.7.25.jar; \
    wget -nv -P ${FLINK_HOME}/lib/ ${SHADED_HADOOP_URL}

# Configure container
COPY --chown=root:root docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

EXPOSE 6123 8081 8082
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ "/bin/bash" ]