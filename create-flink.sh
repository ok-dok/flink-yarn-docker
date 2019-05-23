#!/bin/bash
create_master() {
    docker run -it --name flink-master --network hadoop --network-alias master -h master \
            -p 50010:50010  -p 50020:50020      -p 50070:50070  -p 50075:50075  -p 50090:50090 \
            -p 8020:8020    -p 9000:9000        -p 10020:10020  -p 8030:8030    -p 19888:19888 \
            -p 8031:8031    -p 8032:8032        -p 8033:8033    -p 8040:8040    -p 8042:8042 \
            -p 8088:8088    -p 49707:49707      -p 2122:2122    -p 8081:8081    $1
}

create_slave() {
    docker run -dit --name "flink-slave$1" --network hadoop --network-alias "flink-slave$1" -h "flink-slave$1" \
    -p 50010    -p 50020    -p 50070    -p 50075    -p 50090    -p 8020     -p 9000 \
    -p 10020    -p 8030     -p 19888    -p 8031     -p 8032     -p 8033     -p 8040 \
    -p 8042     -p 8088     -p 49707    -p 2122     $2 
}

help() {
    echo "Usage: `basename $0 ` OPTIONS"
    echo "Options: "
    echo -e "\t -m,\t--master \t\t Create and start a flink container as master"
    echo -e "\t -s,\t--slave number\t\t Create and start a specified number containers of flink as slave"
}
if [[ $# -lt 2 ]]; then
    help
    exit 0
elif [[ "${1:0:1}" = "-" ]]; then
    if [[ "$1" = "-m" || "$1" = "--master" ]]; then
        create_master $2
    elif [[ "$1" = "-s" || "$1" = "--salve" ]]; then
        if [ $# -eq 3 ]; then
            for i in `seq $2`
            do
                create_slave $i $3
            done
        else
            help
            exit 0
        fi
    else
        help
        exit 0
    fi
else
    help
    exit 0
fi


