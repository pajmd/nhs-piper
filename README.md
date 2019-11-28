# NHS-PIPER
This project contains two apps:  
* mongo_sender 
* solr_sender  

Both apps read data from a Kafka pipe fed by scrapy-nhs and send it to mongo and solr.
Each app is launched via the start_piper.sh script wich takes a piper type as a parameter i.e mongo or solr.
The solr,mongo hosts and port, sleep delay used to wait for zookeeper and kafka to be up and running are env variables.

### Usage:

start_piper.sh {mongo | solr}

## Environments variables expected by start_piper.sh:

### Optional:
DELAY default is 5 seconds. Each loop will sleep for DEALY seconds.  
ATTEMPT_NUM number of time the action will be executed. Default is 12 times  

### Required: 
ZOOKEEPER_HOST  
ZOOKEEPER_PORT  
KAFKA_HOST (port is fixed to 2181)  

#### Solr piper
SOLR_HOST  
SOLR_PORT defaulted to 8983  

#### Mongo piper
MONGO_HOST a comma separated list of host:port  
MONGO_REPLICASET name of the replica set  
