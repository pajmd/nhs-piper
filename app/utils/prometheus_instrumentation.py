from prometheus_client import start_http_server, Summary, Counter, Gauge


# Create a metric to track time spent and requests made.
REQUEST_TIME = Summary('nhs_request_processing_seconds', 'Time spent processing request')
# COUNT_REQ = Counter("nhs_message_number", "Number of message received on the pipe", ['tier'])
RECORD_RECEIVED = Counter("nhs_record_number", "Number of message received on the pipe")
RECORD_COMMITTED = Counter("nhs_record_committed", "Number of message received and committed")
NUM_REC_PER_MSG = Gauge('nhs_num_rec_per_msg', 'Number of records per message received')
NUM_FAILURE_PROC_MGS = Counter('nhs_num_failure_proc_mgs', 'Number of failure while processing a message')