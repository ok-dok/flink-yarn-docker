#!/bin/sh
set -ex

service ssh start
gosu hadoop echo N | exec gosu hadoop $HADOOP_HOME/bin/hdfs namenode -format >>/dev/null
gosu hadoop $HADOOP_HOME/sbin/start-dfs.sh
gosu hadoop $HADOOP_HOME/sbin/start-yarn.sh

if [ "$1" = "-d" ]; then
  tail -f $HADOOP_HOME/logs/hadoop-hadoop-datanode-*.log $HADOOP_HOME/logs/hadoop-hadoop-namenode-*.log 
fi

if [ "$1" = "-bash" ]; then
  /bin/bash
fi

exec "$@"
