# nhs-piper docker file

# build: docker build -t nhs_piper .
#
# This image  is used for both mongo and solr piper
# when running the container pass either mongo or solr as a CMD argument
#
# To test:
# As of Docker 18.09.3 the issue needs to be fixed.
# For a workaround:
# See https://github.com/qoomon/docker-host to make the container talk to the container host
# docker run -it --rm --link 'dockerhost' -e KAFKA_HOST='dockerhost' -e MONGO_HOST='dockerhost' -t pjmd-ubuntu:5001/nhs_piper:v0.0.1
#
# I will still be impossible to connect to kafka on the main host, so to do so see:
# https://rmoff.net/2018/08/02/kafka-listeners-explained/
# basically advertise the host IP in kafak server.properties:
# advertised.listeners=PLAINTEXT://192.168.1.3:9092
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

ENTRYPOINT ["./start_piper.sh"]
CMD ["mongo"]
