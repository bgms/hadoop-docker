# Apache Hadoop Docker image

[![DockerPulls](https://img.shields.io/docker/pulls/dvoros/hadoop.svg)](https://registry.hub.docker.com/u/bgmsg/hadoop-docker/)
[![DockerStars](https://img.shields.io/docker/stars/dvoros/hadoop.svg)](https://registry.hub.docker.com/u/bgmsg/hadoop-docker/)

_Note: this is the master branch - for a particular Hadoop version always check the related branch_

# Build the image

If you'd like to try directly from the Dockerfile you can build the image as:

```
docker build -t bgmsg/hadoop-docker:3.3.1 .
```

# Pull the image

The image is also released as an official Docker image from Docker's automated build repository - you can always pull or refer the image when launching containers.

```
docker pull bgmsg/hadoop-docker:3.3.1
```

# Start a container

In order to use the Docker image you have just build or pulled use:

**Make sure that SELinux is disabled on the host. If you are using boot2docker you don't need to do anything.**

```
docker run -it bgmsgg/hadoop-docker:3.3.1 /etc/docker-startup/entrypoint.sh -bash
```

## Testing

You can run one of the stock examples:

```
# run mapreduce
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar grep input output 'dfs[a-z.]+'

# check the output
hdfs dfs -cat output/*
```

## Hadoop native libraries, build
Native build is taken from apache, Below is the oputput
2021-07-20 06:05:45,539 INFO bzip2.Bzip2Factory: Successfully loaded & initialized native-bzip2 library system-native
2021-07-20 06:05:45,542 INFO zlib.ZlibFactory: Successfully loaded & initialized native-zlib library
2021-07-20 06:05:45,580 INFO nativeio.NativeIO: The native code was built without PMDK support.
Native library checking:
hadoop:  true /usr/local/hadoop-3.3.1/lib/native/libhadoop.so.1.0.0
zlib:    true /lib/x86_64-linux-gnu/libz.so.1
zstd  :  true /lib/x86_64-linux-gnu/libzstd.so.1
bzip2:   true /lib/x86_64-linux-gnu/libbz2.so.1
openssl: true /lib/x86_64-linux-gnu/libcrypto.so
ISA-L:   true /lib/x86_64-linux-gnu/libisal.so.2
PMDK:    false The native code was built without PMDK support.
