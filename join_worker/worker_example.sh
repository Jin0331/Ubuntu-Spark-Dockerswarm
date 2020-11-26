#!/bin/bash

docker run -dit --name slave6 --network hadoop --hostname=slave6 sempre813/hadoop_spark-master bash

