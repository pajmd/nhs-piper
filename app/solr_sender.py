from pipers.solr_piper import SolrPiper
from settings import SOLR_GROUP_ID
from utils import log
import logging


logger = logging.getLogger('nsh_app')


def main():
    log.set_logger(logger)
    solr_piper = SolrPiper(SOLR_GROUP_ID)
    solr_piper.consume_pipe()


if __name__ == "__main__":
    main()
