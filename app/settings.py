import os


# Kafka
# pipe
TOPIC = 'scrapypipe'
MONGO_GROUP_ID = 'mongo_feeder'
SOLR_GROUP_ID = 'solr_feeder'
KAFKA_HOST = os.environ.get('KAFKA_HOST', 'localhost')
KAFKA_PORT = os.environ.get('KAFKA_PORT', '9092')
KAFKA_BROKERS = ['%s:%s' % (KAFKA_HOST, KAFKA_PORT)]


def get_mongo_uri():
    mongo_host = os.environ.get('MONGO_HOST', 'localhost')
    mongo_port = os.environ.get('MONGO_PORT', 27017)
    mongo_replicaset = os.environ.get('MONGO_REPLICASET', 'nhsReplicaName')

    if mongo_host.find(',') > -1:
        # mongo_host = host1:port1,host2:port2...
        uri = 'mongodb://%s/replicaSet=%s' % (mongo_host, mongo_replicaset)
    elif mongo_host.find(':') > -1:
        # mongo_host = host1:port1
        uri = 'mongodb://%s/' % (mongo_host)
    else:
        # mongo_host = host1
        uri = 'mongodb://%s:%d/' % (mongo_host, mongo_port)

    return uri


# MONGO
MONGO_URI = get_mongo_uri()
MONGO_DATABASE = os.environ.get('MONGO_DATABASE', 'nhsdb')
COLLECTION_NAME = os.environ.get('COLLECTION_NAME', 'nhsCollection')
VALIDATE_SCHEMA = os.environ.get('VALIDATE_SCHEMA', False)

VALIDATION_SCHEMA =  {
    'validator': {
        '$jsonSchema': [
            {'bsonType': "object"},
            {'required': ["category", "Formulations", "Medicine", "unit", "period", "Pack_Size", "VMPP_Snomed_Code",
                          "Basic_Price"]},
            {'properties': {
                'Medicine': [
                    ('bsonType', "string"),
                    ('description', "must be a string and is required")
                ],
                'Basic_Price': [
                    ('bsonType', "float"),
                    ('description', "must be a float and is required")
                ]
            }
            }
        ]
    }
}

# SOLR
SOLR_HOST = os.environ.get('SOLR_HOST', 'localhost')
SOLR_PORT = os.environ.get('SOLR_PORT', 8983)
