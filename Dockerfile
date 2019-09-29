# nhs-piper docker file

# build: docker build -t nhs_piper .
#
# This image  is used for both mongo and solr piper
# when running the container pass either mongo or solr as a CMD argument
#

FROM bionic-mongo-python

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# RUN echo $(ls -1R .)
# RUN apt-get install -y vim

ENV SOLR_HOST='solr1'
ENV KAFKA_HOST='kafka'
ENV MONGO_HOST='mongo_db'

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

ENTRYPOINT ["/app/start_piper.sh"]
CMD ["mongo"]
