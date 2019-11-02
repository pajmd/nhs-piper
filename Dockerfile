# nhs-piper docker file

# build: docker build -t nhs_piper .
#
# This image  is used for both mongo and solr piper
# when running the container pass either mongo or solr as a CMD argument
#
# To test the container in isolation
# ===================================
# Objective: container is running and connecting to KAFKA and  Mongo running on the local host.
#
# 1) start zookeeper:
#    /home/pjmd/apache-zookeeper-3.5.5-bin/bin/zoo-ensemble.sh start
# 2) start Kafka:
#    ~/kafka_2.12-2.3.0/bin/kafka-server-start.sh ~/kafka_2.12-2.3.0/config/server.properties
# 3) start mongo:
#    sudo service mongod start
# 4) stat dockerhost (container gateway):
#    As of Docker 18.09.3 the issue needs to be fixed.
#    For a workaround:
#    See https://github.com/qoomon/docker-host to make the container talk to the container host
#    tl;dr: run dockerhost that acts as a gateway to the host
#
#    docker run --name 'dockerhost' --cap-add=NET_ADMIN --cap-add=NET_RAW --restart on-failure -d qoomon/docker-host
#
# 5) start nhs-piper:
# docker run -it --rm --link 'dockerhost' -e KAFKA_HOST='dockerhost' -e MONGO_HOST='dockerhost' -t pjmd-ubuntu:5001/nhs_piper:v0.0.1
#
# For kafka to be reachable
# -------------------------
# It will still be impossible to connect to kafka on the main host, so to do so see:
# https://rmoff.net/2018/08/02/kafka-listeners-explained/
# basically advertise the host (now dockerhost) IP in kafak server.properties:
# advertised.listeners=PLAINTEXT://172.17.0.1:9092
#
# For Mongo to be reachable:
#---------------------------
# change /etc/mongod.conf so mongo listens to 0.0.0.0 instead of 127.0.0.1
#

FROM bionic-mongo-python

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

RUN echo $(ls -1R .)
# RUN apt-get install -y vim

ENV SOLR_HOST='solr1'
ENV KAFKA_HOST='kafka'
ENV MONGO_HOST='mongo_db'

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# By default, without overriding any environment variable, when starting the container it will assume
# it is running a mongo piper on one single host (mongo_db mongodb hostname in docker_compose.yaml), default
# port 27017 and defalt replica set nhsReplicaName.
# To running in a customized way, all the environment variables need to be defined. Ex:
# ENV MONGO_HOST='host1:port1,host2:port2'
# ENV
ENTRYPOINT ["./start_piper.sh"]
CMD ["mongo", "mongo_db"]
