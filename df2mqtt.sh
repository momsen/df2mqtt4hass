#!/bin/bash
. ./mqtt_env
PAYLOAD_FILE=$(mktemp)

SENSOR_NAME=$1
SENSOR_ID=$2
MOUNT_SRC=$3

if [ $# -eq 4 ]; then
  DF_CMD=$4
else
  DF_CMD="df -h"
fi

DF_RAW=$($DF_CMD | grep $MOUNT_SRC)
USED_RAW=$(echo $DF_RAW | cut -f3 -d' ')
USED_UNIT=${USED_RAW: -1}
USED_VALUE=${USED_RAW::-1}
FREE_RAW=$(echo $DF_RAW | cut -f4 -d' ')
FREE_UNIT=${FREE_RAW: -1}
FREE_VALUE=${FREE_RAW::-1}
PERCENTAGE_RAW=$(echo $DF_RAW | cut -f5 -d' ')
PERCENTAGE_UNIT=${PERCENTAGE_RAW: -1}
PERCENTAGE_VALUE=${PERCENTAGE_RAW::-1}

cat > $PAYLOAD_FILE <<EOL
{
  "name": "${SENSOR_NAME}_USED",
  "state_topic": "$MQTT_DISCOVERY_BASE/sensor/${SENSOR_ID}_used/state",
  "unit_of_meas": "${USED_UNIT}B"
}
EOL

mosquitto_pub -u $MQTT_USER --pw $MQTT_PW -f $PAYLOAD_FILE -t "$MQTT_DISCOVERY_BASE/sensor/${SENSOR_ID}_used/config" -h $MQTT_HOST -p $MQTT_PORT -i $MQTT_CLIENT -r
mosquitto_pub -u $MQTT_USER --pw $MQTT_PW -m $USED_VALUE -t "$MQTT_DISCOVERY_BASE/sensor/${SENSOR_ID}_used/state" -h $MQTT_HOST -p $MQTT_PORT -i $MQTT_CLIENT -r

cat > $PAYLOAD_FILE <<EOL
{
  "name": "${SENSOR_NAME}_FREE",
  "state_topic": "$MQTT_DISCOVERY_BASE/sensor/${SENSOR_ID}_free/state",
  "unit_of_meas": "${FREE_UNIT}B"
}
EOL

mosquitto_pub -u $MQTT_USER --pw $MQTT_PW -f $PAYLOAD_FILE -t "$MQTT_DISCOVERY_BASE/sensor/${SENSOR_ID}_free/config" -h $MQTT_HOST -p $MQTT_PORT -i $MQTT_CLIENT -r
mosquitto_pub -u $MQTT_USER --pw $MQTT_PW -m $FREE_VALUE -t "$MQTT_DISCOVERY_BASE/sensor/${SENSOR_ID}_free/state" -h $MQTT_HOST -p $MQTT_PORT -i $MQTT_CLIENT -r

cat > $PAYLOAD_FILE <<EOL
{
  "name": "${SENSOR_NAME}_PERCENTAGE_USED",
  "state_topic": "$MQTT_DISCOVERY_BASE/sensor/${SENSOR_ID}_percentage_used/state",
  "unit_of_meas": "${PERCENTAGE_UNIT}"
}
EOL

mosquitto_pub -u $MQTT_USER --pw $MQTT_PW -f $PAYLOAD_FILE -t "$MQTT_DISCOVERY_BASE/sensor/${SENSOR_ID}_percentage_used/config" -h $MQTT_HOST -p $MQTT_PORT -i $MQTT_CLIENT -r
mosquitto_pub -u $MQTT_USER --pw $MQTT_PW -m $PERCENTAGE_VALUE -t "$MQTT_DISCOVERY_BASE/sensor/${SENSOR_ID}_percentage_used/state" -h $MQTT_HOST -p $MQTT_PORT -i $MQTT_CLIENT -r

rm $PAYLOAD_FILE
