# Creates pseudo distributed hadoop
#
# docker build -t dvoros/hadoop .

FROM ubuntu:20.04
MAINTAINER bgmsg

USER root
ENV LANG en_US.UTF-8
ENV TZ=SGT
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y locales  \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen && dpkg-reconfigure --frontend=noninteractive locales\
    && apt-get install -y curl tar sudo lz4 openssh-server openssh-client rsync openjdk-8-jdk libssl-dev libisal-dev vim \
    && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.utf8

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN yes y| ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


# java

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin


# hadoop
RUN curl -sk https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz| tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-3.3.1 hadoop

ENV HADOOP_HOME /usr/local/hadoop
ENV HDFS_NAMENODE_USER root
ENV HDFS_DATANODE_USER root
ENV HDFS_SECONDARYNAMENODE_USER root
ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/hadoop/lib
ENV LIBPATH $LIBPATH:/usr/local/hadoop/lib

RUN echo "JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN echo "HADOOP_HOME=$HADOOP_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

RUN mkdir $HADOOP_HOME/input
RUN cp $HADOOP_HOME/etc/hadoop/*.xml $HADOOP_HOME/input

# pseudo distributed
ADD core-site.xml.template $HADOOP_HOME/etc/hadoop/core-site.xml.template
RUN sed s/HOSTNAME/localhost/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml

# fixing the libhadoop.so like a boss
#RUN rm -rf /usr/local/hadoop/lib/native
#RUN mv /tmp/native /usr/local/hadoop/lib

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config
RUN mkdir /run/sshd && service ssh start

# Make Hadoop executables available on PATH
ENV PATH $PATH:$HADOOP_HOME/bin

# Adding startup files
RUN mkdir /etc/docker-startup
ADD init.sh /etc/docker-startup/init.sh
ADD entrypoint.sh /etc/docker-startup/entrypoint.sh
ADD bootstrap.sh /etc/docker-startup/bootstrap.sh
RUN chown -R root:root /etc/docker-startup
RUN chmod -R 700 /etc/docker-startup

# This creates initial directories, only run this during image building

RUN /etc/docker-startup/init.sh

# Downstream images can use this too start Hadoop services
ENV BOOTSTRAP /etc/docker-startup/bootstrap.sh

CMD ["/etc/docker-startup/entrypoint.sh"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122
