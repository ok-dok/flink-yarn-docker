#!/bin/sh
set -e

. /etc/profile >/dev/null  2>&1

service ssh start

/configure-hadoop.sh

configure() {

  if [ -n "$FLINK_SLAVE_NAMES" ] ; then
    gosu flink echo > $FLINK_HOME/conf/slaves
    for slave in $FLINK_SLAVE_NAMES; do
      gosu flink echo "$slave" >> $FLINK_HOME/conf/slaves
    done
  fi

  # Configure zookeeper servers
  column=`grep -n 'high-availability.zookeeper.quorum'  $FLINK_HOME/conf/flink-conf.yaml | awk -F ':' '{print int($1)}'`
  gosu flink sed -i "${column}c high-availability.zookeeper.quorum: ${ZK_SERVERS}" $FLINK_HOME/conf/flink-conf.yaml
}

configure

if [ "$1" = '-m' ]; then
  /start-dfs-cluster.sh
  /start-yarn-cluster.sh
  sleep 30
  gosu flink $FLINK_HOME/bin/yarn-session.sh -n 3 -jm 4096 -tm 8192 -s 8 -nm FlinkOnYarnSession -d -st
  shift
fi

if [ "$1" = "-d" ]; then
  while true; do sleep 1000; done
fi

exec "$@"
