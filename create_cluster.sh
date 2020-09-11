#! /bin/bash

# build redis-cli tool
wget http://download.redis.io/releases/redis-5.0.9.tar.gz
tar xf redis-5.0.9.tar.gz
make -C ./redis-5.0.9

# 集群节点列表
node_list=($(echo $1 | sed 's/,/ /g'))

# redis-cli 绝对路径
REDIS_CLI=./redis-5.0.9/src/redis-cli

# 集群副本数目
REPLICA_NUM=1

# 待启动集群列表
NODE_LIST=

# 配置生成
generateCfg() {
redis_cfg_file=$1
bind_ip=$2
bind_port=$3

cat <<EOF > ${redis_cfg_file}
bind ${bind_ip}
port ${bind_port}
daemonize yes

pidfile "/var/run/redis/redis-server-${bind_port}.pid"
logfile "/var/log/redis/redis-server-${bind_port}.log"
dir "/var/lib/redis"

save 3600 1
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename "dump-${bind_port}.rdb"

cluster-enabled yes
cluster-config-file nodes-${bind_port}.conf
cluster-node-timeout 5000
EOF
}


for node in ${node_list[@]}
do
    NODE_LIST=$(echo ${NODE_LIST} ${node})
    node_ip=$(echo ${node} | cut -d ':' -f1)
    node_port=$(echo ${node} | cut -d ':' -f2)
    cfg_file=redis-${node_port}.conf
    generateCfg ${cfg_file} ${node_ip} ${node_port}

    echo "scp ${cfg_file} root@${node_ip}:/etc/redis/"
    scp ${cfg_file} root@${node_ip}:/etc/redis/

    echo "ssh root@${node_ip} '(/usr/bin/redis-server /etc/redis/${cfg_file} &)'"
    ssh root@${node_ip} "(/usr/bin/redis-server /etc/redis/${cfg_file} &)"
 done

echo "start cluster: ${REDIS_CLI} --cluster create ${NODE_LIST} --cluster-replicas ${REPLICA_NUM}"
${REDIS_CLI} --cluster create ${NODE_LIST} --cluster-replicas ${REPLICA_NUM}
