#!/usr/bin/env bash



# start_piper.sh
# $1 must be set with the piper type (mongo or solr)
# $2 must be set with db host or with the solr host
# A dbhost can be either a simple hostname like:
#   localhost (no port as it can olny be 27017)
# or
#   hostname1:port1,hostsname2:port2:hostname3:port3
# $3 is optional and defaults to nhsReplicaName. It is the mongo replica set name for a mongo piper

if [ -z $1 ]; then
    echo "Missing piper type and piper host"
	exit 1
elif [ -z $2 ]; then
    echo "Missing piper host"
	exit 2
fi

if [[ $1 == 'mongo' ]]; then
    DB_HOST=$2
    if [[ -z $3 ]]; then
      DB_REPLICASET=$3
    else
      DB_REPLICASET="nhsReplicaName"
    fi
elif [[ $1 == 'solr' ]]; then
    SOLR_HOST=$2
else
    echo "ERROR: Unknown pier type (neither mongo nor solr). Exit!"
    exit 1
fi

check_mongod_up() {
	attempts_left=5
	mongo_hostname=$1
	mongo_replicaset=$2

	while (( attempts_left > 0 )); do

		(( attempts_left-- ))
		if (( attempts_left == 0 )); then
			echo "Mongo still not running. Giving up"
			exit 1
		fi
		if [[ $mongo_hostname == *":"* ]]; then
		  # URI like localhost:27017,localhost:27018'
		  mongo_uri=$mongo_hostname"/replicaSet="$mongo_replicaset
		else
		  mongo_uri=$mongo_hostname":27017"
		fi
		echo "Mongo URI: "$mongo_uri

		mongo_session=`/usr/bin/mongo "mongodb://$mongo_uri" --eval "quit()" | grep "Implicit session"`
		echo "mongo_session= $mongo_session"
		if [ -z "$mongo_session" ]; then
			echo "Waiting for Mongo another " $attempts_left " times"
			sleep 5
		else
			replicaset=`/usr/bin/mongo "mongodb://$mongo_uri" --eval "rs.status()" | grep   $mongo_replicaset`
			echo "The replica set: $replicaset"
			if [ -z "$replicaset" ]; then
				echo "Waiting for Mongo another " $attempts_left " times"
				sleep 5
			else
				break
			fi
		fi
	done
	echo "$mongo_hostname is running!"
}


check_solr_up() {
	attempts_left=12
	solr_url=$1
	while (( attempts_left > 0 )); do

		(( attempts_left-- ))
		if (( attempts_left == 0 )); then
			echo "$solr_url still not running or nhsCollection not ready. Giving up"
			exit 1
		fi
		echo "==========================================="
		# wget -o /dev/null -O - "http://solr1:8983/solr/nhsCollection/admin/luke/?show=schema&wt=json" | grep "stuff"
		# res=`wget -o /dev/null -O - "$solr_url/solr/nhsCollection/select?q=*%3A*&spellcheck=on" | grep response`
		res=`wget -o /dev/null -O - "$solr_url/solr/nhsCollection/admin/luke/?show=schema&wt=json" | grep "VMPP Snomed Code"`
		# res=`wget -q -O - "$solr_url" | grep -i solr`
		echo "wget result: $res"
		if [ -z "$res" ] ; then
			echo "Waiting for $solr_url and nhsCollection another " $attempts_left " times"
			sleep 5
		else
		    break
		fi
	done
	echo " $solr_url is running and nhsCollection ready!"

}

if [[ $1 == 'solr' ]]; then
    check_solr_up "http://$SOLR_HOST:8983"
else
  # $DB_HOST is either a simple hostname like localhost (no port as it can olny be 27017)
  # or hostname1:port1,hostsname2:port2:hostname3:port3
  #
    check_mongod_up $DB_HOST $DB_REPLICASET
fi

cd app
python $1_sender.py
