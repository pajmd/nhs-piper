#!/usr/bin/env bash



# start_piper.sh
# $1 must be set with the piper type (mongo or solr)
# The others parameters are set as environment variables
#
# $2 must be set with db host or with the solr host
# A dbhost can be either a simple hostname like:
#   localhost (no port as it can olny be 27017)
# or
#   hostname1:port1,hostsname2:port2:hostname3:port3
# $3 is optional and defaults to nhsReplicaName. It is the mongo replica set name for a mongo piper

SLEEP_TIME=${DELAY:-5}
ATTEMPTS_LEFT=${ATTEMPT_NUM:-12}
# No longer defaulting mongo replicaset. All env variables MUST be set
#DEFAULT_REPLICASET="nhsReplicaName"

# check parameters and env variables are set properly
if [ -z "$1" ]; then
  echo "Missing piper type"
	exit 1
elif [[ -z $ZOOKEEPER_HOST ]]; then
  echo "Missing zookeeper host"
  exit 1
elif [[ -z $ZOOKEEPER_PORT ]]; then
  echo "Missing zookeeper port"
  exit 1
elif [[ -z $KAFKA_HOST ]]; then
  echo "Missing kafka host"
  exit 1
elif [[ $1 == "solr" ]]; then
  if [[ -z $SOLR_HOST ]]; then
    echo "Missing solr host"
    exit 1
  else
    SOLR_PORT=${SOLR_PORT:-8983}
    SOLR_URL="http://$SOLR_HOST:$SOLR_PORT"
  fi
elif [[ $1 == "mongo" ]]; then
  if [[ -z $MONGO_HOST ]]; then
    echo "Missing mongo host"
    exit 1
  elif [[ -z $MONGO_REPLICASET ]]; then
      echo "Missing mongo replicaset"
      exit 1
  fi
else
  echo "Unknown piper type"
  exit 1
fi


check_mongod_up() {
	attempts_left=$ATTEMPTS_LEFT

	while (( attempts_left > 0 )); do

		(( attempts_left-- ))
		if (( attempts_left == 0 )); then
			echo "Mongo still not running. Giving up"
			return 1
		fi
		if [[ $MONGO_HOST == *":"* ]]; then
		  # URI like localhost:27017,localhost:27018'
		  mongo_uri=$MONGO_HOST"/replicaSet="$MONGO_REPLICASET
		else
		  mongo_uri=$MONGO_HOST":27017"
		fi
		echo "Mongo URI: ""$mongo_uri"

		mongo_session=$(/usr/bin/mongo "mongodb://$mongo_uri" --eval "quit()" | grep "Implicit session")
		echo "mongo_session= $mongo_session"
		if [ -z "$mongo_session" ]; then
			echo "Waiting  $SLEEP_TIME sec for Mongo, another " $attempts_left " times"
			sleep $SLEEP_TIME
		else
			replicaset=$(/usr/bin/mongo "mongodb://$mongo_uri" --eval "rs.status()" | grep   $MONGO_REPLICASET)
			echo "The replica set: $replicaset"
			if [ -z "$replicaset" ]; then
				echo "Waiting $SLEEP_TIME sec for Mongo replica to be up, another " $attempts_left " times"
				sleep $SLEEP_TIME
			else
				break
			fi
		fi
	done
	echo "$MONGO_HOST is running!"
}


check_solr_up() {
	attempts_left=$ATTEMPTS_LEFT
	while (( attempts_left > 0 )); do

		(( attempts_left-- ))
		if (( attempts_left == 0 )); then
			echo "$SOLR_URL still not running or nhsCollection not ready. Giving up"
			return 1
		fi
		echo "==========================================="
		# wget -o /dev/null -O - "http://solr1:8983/solr/nhsCollection/admin/luke/?show=schema&wt=json" | grep "stuff"
		# res=`wget -o /dev/null -O - "$SOLR_URL/solr/nhsCollection/select?q=*%3A*&spellcheck=on" | grep response`
		res=`wget -o /dev/null -O - "$SOLR_URL/solr/nhsCollection/admin/luke/?show=schema&wt=json" | grep "VMPP Snomed Code"`
		# res=`wget -q -O - "$SOLR_URL" | grep -i solr`
		echo "wget result: $res"
		if [ -z "$res" ] ; then
			echo "Waiting for $SOLR_URL and nhsCollection another " $attempts_left " times"
			sleep $SLEEP_TIME
		else
		    break
		fi
	done
	echo " $SOLR_URL is running and nhsCollection ready!"

}

check_kafka_up() {
    MAX=25
    COUNTER=0
    while [  $COUNTER -lt $MAX ]; do
      brokers=$(echo dump | nc "$ZOOKEEPER_HOST" "$ZOOKEEPER_PORT" | grep brokers)
      if [ $? -eq 1 ] || [ -z "$brokers" ]; then
        echo "Kafka is NOT running , waiting $SLEEP_TIME sec. $COUNTER attempts...";
        # COUNTER=`expr $COUNTER + 1`;
        COUNTER=$((COUNTER + 1));
        sleep $SLEEP_TIME;
      else
        echo "Kafka is running ";
        break;
      fi
    done;
    if [ $COUNTER -eq $MAX ]; then
      echo "Kafka not running. Giving up .........";
      return 1;
    fi
}

if check_kafka_up; then
  if [[ $1 == 'solr' ]]; then
      check_solr_up
  else
    # $DB_HOST is either a simple hostname like localhost (no port as it can olny be 27017)
    # or hostname1:port1,hostsname2:port2:hostname3:port3
    #
      check_mongod_up
  fi
else
  echo "Kafka not ready cannot start $1 piper"
  exit 1
fi

if [[ $? -eq 0 ]]; then
  echo "Starting $1_sender"
  cd app || exit 1
  python $1_sender.py
else 
  echo "$1 not ready, could NOT start $1_sender"
  exit 1
fi
