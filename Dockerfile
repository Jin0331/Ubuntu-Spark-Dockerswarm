FROM sempre813/ubuntu-hadoop:v3.1.1
MAINTAINER sempre813

USER root

# spark 2.4.5 without Hadoop
RUN wget https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop.tgz \
    && tar -xvzf spark-2.4.5-bin-without-hadoop.tgz -C /usr/local \
    && cd /usr/local && ln -s ./spark-2.4.5-bin-without-hadoop spark \
    && rm -f /spark-2.4.5-bin-without-hadoop.tgz

# ENV hadoop
ENV HADOOP_COMMON_HOME=/usr/local/hadoop \
    HADOOP_HDFS_HOME=/usr/local/hadoop \
    HADOOP_MAPRED_HOME=/usr/local/hadoop \
    HADOOP_YARN_HOME=/usr/local/hadoop \
    HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop \
    YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop

ENV LD_LIBRARY_PATH=/usr/local/hadoop/lib/native/:$LD_LIBRARY_PATH

# ENV spark
ENV SPARK_HOME /usr/local/spark
ENV PATH $PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

## spark-env.sh config
RUN cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh \
    && echo SPARK_WORKER_CORES=7 >> $SPARK_HOME/conf/spark-env.sh \
    && echo SPARK_WORKER_MEMORY=25G >> $SPARK_HOME/conf/spark-env.sh \
    && echo ARROW_PRE_0_15_IPC_FORMAT=1 >> $SPARK_HOME/conf/spark-env.sh \
    && echo export SPARK_DIST_CLASSPATH=$(/usr/local/hadoop/bin/hadoop classpath) >> $SPARK_HOME/conf/spark-env.sh \
    && echo export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop >> $SPARK_HOME/conf/spark-env.sh \
    && echo export SPARK_CLASSPATH=$SPARK_HOME/jars >> $SPARK_HOME/conf/spark-env.sh \
    && echo export JAVA_HOME=/usr/java/default >> $SPARK_HOME/conf/spark-env.sh \
    && echo export PYSPARK_PYTHON=/usr/bin/python3 >> $SPARK_HOME/conf/spark-env.sh \
    && echo export PYSPARK_DRIVER_PYTHON=/usr/bin/python3 >> $SPARK_HOME/conf/spark-env.sh

## spark-defaults config & slaves
RUN mkdir /tmp/spark-events

ADD workers $HADOOP_HOME/etc/hadoop/workers
RUN cp $HADOOP_HOME/etc/hadoop/workers $SPARK_HOME/conf/slaves


#COPY .py files
COPY script/hadoop_spark_slaves.py /root/hadoop_spark_slaves.py
COPY script/hdfsupload.py /root/hdfsupload.py

RUN chown root.root /root/hadoop_spark_slaves.py \
    && chmod 700 /root/hadoop_spark_slaves.py \
    && chown root.root /root/hdfsupload.py \
    && chmod 700 /root/hdfsupload.py

## install findspark
RUN pip3 install findspark pyarrow pandas

## install sparklyr
RUN apt-get install -y libgit2-dev && \
    Rscript -e 'install.packages("devtools")' && \
    Rscript -e 'devtools::install_github("rstudio/sparklyr")'

#COPY scala JAR file
COPY jar/scalaudf_2.11-0.1.jar /usr/local/spark/jars/scalaudf_2.11-0.1.jar
RUN chown root.root /usr/local/spark/jars/scalaudf_2.11-0.1.jar \
    && chmod 700 /usr/local/spark/jars/scalaudf_2.11-0.1.jar

COPY jar/index2dict_2.11-0.1.jar /usr/local/spark/jars/index2dict_2.11-0.1.jar
RUN chown root.root /usr/local/spark/jars/index2dict_2.11-0.1.jar \
    && chmod 700 /usr/local/spark/jars/index2dict_2.11-0.1.jar

# RUN openssh-server
RUN service ssh start

# Spark Web UI, History Server Port
EXPOSE 7077 8080 9797 9898 18080
