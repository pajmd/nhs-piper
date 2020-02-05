from pipers.mongo_piper import MongoPiper
from settings import MONGO_GROUP_ID
from utils import log, prometheus_instrumentation
import logging


# Here I decided to use the "root" logger, litteraly called root
# I could have named it as logger = logging.getLogger("nhs-app"), but
# in this case for the sub modules to inherit this root logger called "nhs-app"
# I would have to used the dot syntax in the sub modules:
# logger = logging.getLogger("nhs-app.%s" % __name__)
# the drawback using an empty name as root i.e. "root" is that third party
# module will likely show their logging
logger = logging.getLogger()


def main():
    log.set_logger(logger)

    logger.debug("Starting mongo sender")
    prometheus_instrumentation.start_http_server(9902)
    mongo_piper = MongoPiper(MONGO_GROUP_ID)
    mongo_piper.consume_pipe()


if __name__ == "__main__":
    main()
