from pipers.piper import Piper
from settings import (
    MONGO_URI, MONGO_DATABASE, COLLECTION_NAME
)
from db.store import DbClient
import logging


logger = logging.getLogger(__name__)

class MongoPiper(Piper):

    def process_records(self, nhs_records):
        logger.debug("processing %d records" % len(nhs_records))
        logger.debug("DB details: %s - %s - %s" % (MONGO_URI, MONGO_DATABASE, COLLECTION_NAME))
        with DbClient(MONGO_URI, MONGO_DATABASE, COLLECTION_NAME) as db:
            db.insert_documents(nhs_records)