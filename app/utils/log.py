import logging


# https://docs.python.org/3/howto/logging-cookbook.html
# https://docs.python.org/3/library/logging.html

class NoKafkaLoggingFilter(logging.Filter):
    def filter(self, record):
        return not record.name.startswith('kafka')

def set_logger(logger):
    logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(name)s - %(filename)s: %(lineno)d  - %(message)s')
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    logger.addFilter(NoKafkaLoggingFilter())

