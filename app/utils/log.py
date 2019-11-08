import logging


# https://docs.python.org/3/howto/logging-cookbook.html
# https://docs.python.org/3/library/logging.html
# https://www.saltycrane.com/blog/2014/02/python-logging-filters-do-not-propagate-like-handlers-and-levels-do/

class NoKafkaLoggingFilter(logging.Filter):
    def filter(self, record):
        return not (record.name.startswith('kafka') and record.levelname == 'DEBUG')


def set_logger(logger):
    logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(name)s - %(filename)s: %(lineno)d  - %(message)s')
    ch.setFormatter(formatter)
    ch.addFilter(NoKafkaLoggingFilter())
    logger.addHandler(ch)
    # logger.addFilter(NoKafkaLoggingFilter())

