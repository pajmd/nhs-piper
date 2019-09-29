from app.pipers.solr_piper import SolrPiper
from app.settings import SOLR_GROUP_ID
from app.utils import log
import logging


logger = logging.getLogger(__name__)


def main():
    log.set_logger(logger)
    solr_piper = SolrPiper(SOLR_GROUP_ID)
    solr_piper.consume_pipe()


if __name__ == "__main__":
    main()
