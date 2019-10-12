from pipers.piper import Piper
from settings import COLLECTION_NAME
from search_engine import solr
import uuid
import time
import logging


logger = logging.getLogger(__name__)


class SolrPiper(Piper):
    def process_records(self, nhs_records):

        def make_solr_record(nhs_record):
            nhs_record['ns'] = COLLECTION_NAME
            nhs_record['_ts'] = time.time()
            nhs_record['id'] = uuid.uuid4().hex
            nhs_record.pop('url')
            nhs_record.pop('filename')
            nhs_record.pop('digest')
            return nhs_record

        solr_nhs_records = [make_solr_record(nhs_record) for nhs_record in nhs_records]
        solr.send(solr_nhs_records)


