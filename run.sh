createTable() {
  docker exec \
    -t pinot-controller \
    bin/pinot-admin.sh AddTable \
    -schemaFile ../../static/schema/transcript.json \
    -tableConfigFile ../../static/table/transcript.json \
    -exec
}

query() {
  query="${1:-SELECT * FROM transcript}"

  docker exec \
    -i pinot-controller \
    bin/pinot-admin.sh PostQuery \
    -brokerHost pinot-broker \
    -brokerPort 8099 \
    -query "$query"
}

createTopic() {
  topic_name="${1:-transcript-topic}"

  docker exec \
  -t kafka \
  /opt/kafka/bin/kafka-topics.sh \
  --zookeeper pinot-zookeeper:2181/kafka \
  --partitions=1 --replication-factor=1 \
  --create --topic $topic_name
}

publishMessages() {
  docker exec \
   -i kafka \
  /opt/kafka/bin/kafka-console-producer.sh \
  --broker-list kafka:9092 \
  --topic transcript-topic < ./static/data/transcript.json
}
