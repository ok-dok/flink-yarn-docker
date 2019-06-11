# Flink-1.8.0-HA with Hadoop-2.9.2-HA Docker image

基于Hadoop 2.9.2-HA镜像版本（docker镜像地址：[https://hub.docker.com/r/okdokey/hadoop](#https://hub.docker.com/r/okdokey/hadoop), 命令：```docker pull okdokey/hadoop:2.9.2-HA```），使用docker搭建Flink on yarn的高可用集群，高可用包含hdfs namenode HA，yarn HA， flink on yarn

## 使用说明

Flink on yarn 高可用集群依赖于Zookeeper，此镜像中不包含zookeeper，因此需要单独提供zookeeper服务。
要运行Flink on yarn HA集群，有两种方式可选：直接从docker hub拉取相关镜像并启动容器，或者自行构建。

### 1. 从DockerHub拉取镜像

```
docker pull okdokey/zookeeper:3.4.14
docker pull okdokey/flink-yarn:1.8.0
```

#### 启动服务集群

镜像中包含了Flink，但在启动集群时并不会启动Flink，而只是启动Hadoop HA集群，Flink需要在Hadoop集群正常运行后，再手动启动执行。

命令：
```
docker-compose -f docker-compose.yml up     #初次启动容器集群
docker-compose -f docker-compose.yml start  #启动容器服务集群
docker-compose -f docker-compose.yml stop   #关闭容器服务集群
```
访问localhost:8088 查看Hadoop集群启动情况，待三个节点正常运行后，执行下面的命令以启动Flink 在 YARN 集群上运行。

```
docker exec -it flink-hadoop-nn1-rm1 gosu flink /opt/flink/bin/yarn-session.sh -n 3 -jm 1024 -tm 1024 -d -st
```
flink相关启动参数可以自行调整。

编写docker-compoose.yml文件，内容参考如下：

```yaml
ersion: "2"
services:
    flink-hadoop1:
        image: okdokey/flink-yarn:1.8.0
        container_name: flink-hadoop-nn1-rm1
        hostname: flink-hadoop-nn1-rm1
        depends_on:
            - zk1
            - zk2
            - zk3
        networks:
            hadoop:
                aliases:
                    - master
                    - nn1
                    - rm1
        environment:
            ZK_SERVERS: zk1:2181,zk2:2181,zk3:2181
            HADOOP_WORKER_NAMES: flink-hadoop1 flink-hadoop2 flink-hadoop3
            HDFS_JOURNAL_NODES: flink-hadoop1:8485,flink-hadoop2:8485,flink-hadoop3:8485
            FLINK_SLAVE_NAMES: flink-hadoop1 flink-hadoop2 flink-hadoop3
            YARN_RM_AM_MAX_ATTEMPTS: 4
            YARN_APP_MIN_MEMORY: 512
            YARN_APP_MAX_MEMORY: 4096
            YARN_NM_MEMROY: 4096
            YARN_NM_VMEM_PMEM_RATIO: 5
            YARN_NM_CPU_VCORES: 2
            FLINK_TM_SLOTS: 2
        ports:
            - "8020:8020"
            - "8030:8030"
            - "8031:8031"
            - "8032:8032"
            - "8033:8033"
            - "8042:8042"
            - "8044:8044"
            - "8045:8045"
            - "8046:8046"
            - "8047:8047"
            - "8048:8048"
            - "8049:8049"
            - "8088:8088"
            - "8089:8089"
            - "8090:8090"
            - "8091:8091"
            - "8188:8188"
            - "8190:8190"
            - "8480:8480"
            - "8481:8481"
            - "8485:8485"
            - "8788:8788"
            - "10200:10200"
            - "50010:50010"
            - "50020:50020"
            - "50070:50070"
            - "50075:50075"
            - "10020:10020"
            - "19888:19888"
            - "19890:19890"
            - "10033:10033"
            - "8081:8081"
            - "8082:8082"
        command: [ "-m", "-d" ]
        
    flink-hadoop2: 
        image: okdokey/flink-yarn:1.8.0
        container_name: flink-hadoop-nn2-rm2
        hostname: flink-hadoop-nn2-rm2
        depends_on:
            - zk1
            - zk2
            - zk3
        networks:
            hadoop:
                aliases:
                    - standby
                    - nn2
                    - rm2
        environment:
            ZK_SERVERS: zk1:2181,zk2:2181,zk3:2181
            HADOOP_WORKER_NAMES: flink-hadoop1 flink-hadoop2 flink-hadoop3
            HDFS_JOURNAL_NODES: flink-hadoop1:8485,flink-hadoop2:8485,flink-hadoop3:8485
            FLINK_SLAVE_NAMES: flink-hadoop1 flink-hadoop2 flink-hadoop3
            YARN_RM_AM_MAX_ATTEMPTS: 4
            YARN_APP_MIN_MEMORY: 512
            YARN_APP_MAX_MEMORY: 4096
            YARN_NM_MEMROY: 4096
            YARN_NM_VMEM_PMEM_RATIO: 5
            YARN_NM_CPU_VCORES: 2
            FLINK_TM_SLOTS: 2
        ports:
            - "9088:8088"
            - "50071:50070"

        command: [ "-d" ]
        
    flink-hadoop3: 
        image: okdokey/flink-yarn:1.8.0
        container_name: flink-hadoop-slave1
        hostname: flink-hadoop-slave1
        depends_on:
            - zk1
            - zk2
            - zk3
        networks:
            hadoop:
                aliases:
                    - slave1
        environment:
            ZK_SERVERS: zk1:2181,zk2:2181,zk3:2181
            HADOOP_WORKER_NAMES: flink-hadoop1 flink-hadoop2 flink-hadoop3
            HDFS_JOURNAL_NODES: flink-hadoop1:8485,flink-hadoop2:8485,flink-hadoop3:8485 
            FLINK_SLAVE_NAMES: flink-hadoop1 flink-hadoop2 flink-hadoop3
            YARN_RM_AM_MAX_ATTEMPTS: 4
            YARN_APP_MIN_MEMORY: 512
            YARN_APP_MAX_MEMORY: 4096
            YARN_NM_MEMROY: 4096
            YARN_NM_VMEM_PMEM_RATIO: 5
            YARN_NM_CPU_VCORES: 2
            FLINK_TM_SLOTS: 2
        command: [ "-d" ]

    zk1:
        image: okdokey/zookeeper:3.4.14
        hostname: zk1
        container_name: zk1
        networks: 
            hadoop:
                aliases:
                    - zk1
        ports:
            - 2181:2181
        environment:
            ZK_MY_ID: 1
            ZK_SERVERS: server.1=0.0.0.0:2888:3888 server.2=zk2:2888:3888 server.3=zk3:2888:3888

    zk2:
        image: okdokey/zookeeper:3.4.14
        hostname: zk2
        container_name: zk2
        networks: 
            hadoop:
                aliases:
                    - zk2
        ports:
            - 2182:2181
        environment:
            ZK_MY_ID: 2
            ZK_SERVERS: server.1=zk1:2888:3888 server.2=0.0.0.0:2888:3888 server.3=zk3:2888:3888

    zk3:
        image: okdokey/zookeeper:3.4.14
        hostname: zk3
        container_name: zk3
        networks: 
            hadoop:
                aliases:
                    - zk3
        ports:
            - 2183:2181
        environment:
            ZK_MY_ID: 3
            ZK_SERVERS: server.1=zk1:2888:3888 server.2=zk2:2888:3888 server.3=0.0.0.0:2888:3888
networks: 
    hadoop:
```
## 2. 自行构建镜像

你可以选择直接从Dockerfile构建，构建目录在docker-build，命令如下：

```
docker build -t flink-yarn:1.8.0 docker-build/
```
然后使用`docker-compose`启动集群即可。

正常情况这样hadoop高可用集群就启动成功了，访问localhost:8088可以查看yarn集群状态，localhost:50070可以查看dfs状态
