#!/bin/sh
set -e

setconf() {
  FLINK_CONF_FILE=$FLINK_HOME/conf/flink-conf.yaml
  KEY=$1
  VALUE=$2
  FILE=$3
  sed -i "s#${KEY}:.*#${KEY}: ${VALUE}#g" $FLINK_CONF_FILE
}

configure_flink() {
  

  if [ -n "$FLINK_SLAVE_NAMES" ] ; then
    gosu flink echo > $FLINK_HOME/conf/slaves
    for slave in $FLINK_SLAVE_NAMES; do
      gosu flink echo "$slave" >> $FLINK_HOME/conf/slaves
    done
  fi

  # Configure zookeeper servers
  if [ -n ${ZK_SERVERS} ]; then
    # sed -i "s#high-availability.zookeeper.quorum:.*#high-availability.zookeeper.quorum: ${ZK_SERVERS}" $FLINK_CONF_FILE
    setconf "high-availability.zookeeper.quorum" "${ZK_SERVERS}"
  fi

  # Configure jobmanager rpc port
  if [ -n $FLINK_JM_RPC_PORT ]; then
    setconf "jobmanager.rpc.port" "${FLINK_JM_RPC_PORT}"
  fi

  # Configure jobmanager heap size
  if [ -n $FLINK_JM_HEAP_SIZE ]; then
    setconf "jobmanager.heap.size" "${FLINK_JM_HEAP_SIZE}"
  fi

  # Configure taskmanager heap size
  if [ -n $FLINK_TM_HEAP_SIZE ]; then
    setconf "taskmanager.heap.size" "${FLINK_TM_HEAP_SIZE}"
  fi

  # Configure taskmanager heap size
  if [ -n ${FLINK_TM_SLOTS} ]; then
    setconf "taskmanager.numberOfTaskSlots" "${FLINK_TM_SLOTS}"
  fi
}

. /etc/profile >/dev/null  2>&1

service ssh start

/configure-hadoop.sh

configure_flink

if [ "$1" = '-m' ]; then
  /start-dfs-cluster.sh
  /start-yarn-cluster.sh
  # sleep 100
  # gosu flink $FLINK_HOME/bin/yarn-session.sh -n 3 -jm 1024 -tm 1024 -s 2 -nm FlinkOnYarnSession -d -st
  shift
fi

if [ "$1" = "-d" ]; then
  while true; do sleep 1000; done
fi

exec "$@"
