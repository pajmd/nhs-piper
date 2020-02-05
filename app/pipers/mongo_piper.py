from pipers.piper import Piper
from settings import (
    MONGO_URI, MONGO_DATABASE, COLLECTION_NAME
)
from db.store import DbClient
from utils.prometheus_instrumentation import REQUEST_TIME
import logging


logger = logging.getLogger(__name__)


class MongoPiper(Piper):

    def __init__(self, group_id):
        super().__init__(group_id)
        # initialize / connect to the DB
        try:
            self.db = DbClient(MONGO_URI, MONGO_DATABASE, COLLECTION_NAME)
        except Exception as ex:
            logger.exception("Something went wong with the DB")
            raise

    @REQUEST_TIME.time()
    def process_records(self, nhs_records):
        logger.debug("processing %d records" % len(nhs_records))
        logger.debug("DB details: %s - %s - %s" % (MONGO_URI, MONGO_DATABASE, COLLECTION_NAME))
        try :
            logger.debug("Inserting docs")
            self.db.insert_documents(nhs_records)
        except Exception as ex:
            logger.exception("Something went wong with the DB")
            raise
