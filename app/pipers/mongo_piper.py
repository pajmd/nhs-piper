from app.pipers.piper import Piper
from app.settings import (
    MONGO_URI, MONGO_DATABASE, COLLECTION_NAME
)
from app.db.store import DbClient
import logging


logger = logging.getLogger(__name__)

class MongoPiper(Piper):

    def process_records(self, nhs_records):
        with DbClient(MONGO_URI, MONGO_DATABASE, COLLECTION_NAME) as db:
            db.insert_documents(nhs_records)