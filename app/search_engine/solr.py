from settings import SOLR_HOST, SOLR_PORT, COLLECTION_NAME
from search_engine.solrclient.solrclient import SolrClient


def send(records):
    client = SolrClient(host=SOLR_HOST, port=SOLR_PORT)
    client.add_documents(COLLECTION_NAME, records)