#!/bin/sh
set -ex

service ssh start
echo N | hdfs namenode -format
gosu hadoop $HADOOP_HOME/sbin/start-dfs.sh
gosu hadoop $HADOOP_HOME/sbin/start-yarn.sh

if [ "$1" = "-d" ]; then
  tail -f $HADOOP_HOME/logs/*
fi

if [ "$1" == "-bash" ]; then
  /bin/bash
fi

exec "$@"
