#!/bin/bash


# hdfs    ------> hdfs dfs -mkdir -p /spark/share-log?
# jupyter ------> jupyter notebook --allow-rot
# vscode  ------> ./code-server
# --hostname=master

# master
docker run -dit -v /home/dblab/data:/usr/local/etc --name master --hostname=master --network hadoop \
 -p 8989:8989 -p 8888:8888 -p 8081:8081 -p 4040:4040 -p 18080:18080 -p 9870:9870 -p 9000:9000 -p 8088:8088 -p 8042:8042 -p 8085:8080 -p 2122:22 \
 --cpuset-cpus=0-3 -m 35g --memory-swap=40g sempre813/hadoop_spark-master:latest bash


# slaves
docker run -dit --name slave1 --hostname=slave1 --network hadoop --cpuset-cpus=4-6 -m 25g --memory-swap=26g sempre813/hadoop_spark-master:latest bash

docker run -dit --name slave2 --hostname=slave2 --network hadoop --cpuset-cpus=7-9 -m 25g --memory-swap=26g sempre813/hadoop_spark-master:latest bash

docker run -dit --name slave3 --hostname=slave3 --network hadoop --cpuset-cpus=10-12 -m 25g --memory-swap=26g sempre813/hadoop_spark-master:latest bash

docker run -dit --name slave4 --hostname=slave4 --network hadoop --cpuset-cpus=13-15 -m 25g --memory-swap=26g sempre813/hadoop_spark-master:latest bash
