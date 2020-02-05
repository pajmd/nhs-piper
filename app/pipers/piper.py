from abc import abstractmethod, ABCMeta
from kafka import KafkaConsumer, errors
from json import loads
from settings import (
    TOPIC, KAFKA_BROKERS
)
from pipers.errors import PiperNoBrokerAvailable
from utils.prometheus_instrumentation import RECORD_COMMITTED, RECORD_RECEIVED, NUM_REC_PER_MSG, NUM_FAILURE_PROC_MGS
import threading
import time
import logging


logger = logging.getLogger(__name__)

MAX_RECORDS = 10
MAX_POLL_TIME = 1000  # 1 sec


class Piper(object):
    __metaclass__ = ABCMeta

    def __init__(self, group_id, max_poll_time=MAX_POLL_TIME, max_records=MAX_RECORDS):
        # shutdown hook
        threading.Thread.__init__(self)
        self.stop_event = threading.Event()

        self.num_poll_attempts = 1
        self.poll_waiting_time = 5  # 5 sec
        logger.info("Kafka Brokers: %s" % KAFKA_BROKERS)
        self.max_poll_time = max_poll_time
        self.max_records = max_records
        connected_to_broker = False
        for attempts in range(6):
            try:
                self.consumer = KafkaConsumer(
                    TOPIC,
                    bootstrap_servers=KAFKA_BROKERS,
                    auto_offset_reset='earliest',
                    enable_auto_commit=False,
                    max_poll_records=self.max_records,
                    max_poll_interval_ms=120000,  # ms
                    # consumer_timeout_ms=10,  # ms
                    group_id=group_id,
                    value_deserializer=lambda x: loads(x.decode('utf-8')))
                logger.debug("Connected to Kafka")
                connected_to_broker = True
                break
            except errors.NoBrokersAvailable as ex:
                logger.exception(" Attempt %d - Failed finding a broker, wait 5 sec" % attempts)
                time.sleep(5)
        if not connected_to_broker:
            raise PiperNoBrokerAvailable("Failed connecting to Kafka")

    def stop(self):
        # it should be called when catching a signal
        self.stop_event.set()

    def consume_pipe(self):
        logger.debug('Entering the consumer loop')
        while not self.stop_event.is_set():
            logger.debug('In the consumer loop')
            try:
                nhs_records = []
                records = self.consumer.poll(self.max_poll_time, self.max_records)
                logger.debug("Returned from polling")
                if records:
                    logger.debug("Received %d records" % len(records))
                    for topic_partition, consumer_records in records.items():
                        logger.debug('topic: %s, partition=%d' % (topic_partition.topic, topic_partition.partition))
                        logger.debug(consumer_records)
                        for record in consumer_records:
                            logger.debug("Record offset: %d" % record.offset)
                            self.populate_nhs_records(nhs_records, record)
                            # nhs_records.append(record.value['doc'])
                    try:
                        with NUM_FAILURE_PROC_MGS.count_exceptions():
                            RECORD_RECEIVED.inc(len(nhs_records))
                            NUM_REC_PER_MSG.set(len(nhs_records))
                            self.process_records(nhs_records)
                            self.consumer.commit()
                            RECORD_COMMITTED.inc(len(nhs_records))
                            self.reset_throttle_polling()
                    except Exception as ex:  # create exception DB and solr specific
                        logger.exception('Error while storing or indexing data: %s' % ex)
                        # not sure it will help much bc if something is wrong with the record
                        # eventually the record will be picked by another piper instance.
                        # At the end we will exhaust all instances and stall
                        # Therefore I decided to commit anyway
                        self.consumer.commit()
                        # self.throttle_polling()
                else:
                    logger.debug("No record received")
                    time.sleep(2)

            except Exception as ex:  # create exception DB and solr specific
                logger.exception('Error while polling: %s' % ex)
                logger.debug('Closed consumer')
                time.sleep(5)

        self.consumer.close()

    @abstractmethod
    def process_records(self, records):
        pass

    @staticmethod
    def populate_nhs_records(nhs_records, record):
        bulk = record.value['doc'].get('bulk')
        filename = record.value['doc'].get('filename')
        if filename:
            logger.debug("Received chunks for %s" % filename)
        if bulk is None:
            nhs_records.append(record.value['doc'])
        else:
            nhs_records.extend(bulk)

    def throttle_polling(self):
        self.poll_waiting_time = self.poll_waiting_time * self.num_poll_attempts
        print("Throttling, waiting: %d seconds" % self.poll_waiting_time)
        time.sleep(self.poll_waiting_time)
        self.num_poll_attempts += 1

    def reset_throttle_polling(self):
        self.num_poll_attempts = 1

