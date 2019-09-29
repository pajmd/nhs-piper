from app.pipers.mongo_piper import MongoPiper
from app.settings import MONGO_GROUP_ID
from app.utils import log
import logging


logger = logging.getLogger(__name__)


def main():
    log.set_logger(logger)
    mongo_piper = MongoPiper(MONGO_GROUP_ID)
    mongo_piper.consume_pipe()


if __name__ == "__main__":
    main()
