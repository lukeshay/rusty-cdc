#!/bin/bash

RUSTY_CDC_PROJECT_ID="rusty-cdc-lcl"

RUSTY_CDC_TOPIC="rusty-cdc"

start_emulator() {
    project_id="${1}"

    echo "Starting emulator for project ${project_id}"
    gcloud beta emulators pubsub start --project "${project_id}" --host-port=0.0.0.0:3334 &
}

create_topic() {
    project_id="${1}"
    topic_name="${2}"

    echo "Adding ${topic_name} SVPC topic to ${project_id}"
    curl -s -X PUT "http://localhost:3334/v1/projects/${project_id}/topics/${topic_name}"
}

create_subscription() {
    project_id="${1}"
    topic_name="${2}"

    echo "Adding ${topic_name} SVPC subscription to ${project_id}"
    curl -s -X PUT "http://localhost:3334/v1/projects/${project_id}/subscriptions/${topic_name}-subscription" \
        -H 'Content-Type: application/json' \
        -d "{\"topic\": \"projects/${project_id}/topics/${topic_name}\", \"ackDeadlineSeconds\": 20}"
}

start_emulator "${RUSTY_CDC_PROJECT_ID}"

echo "Waiting for ${RUSTY_CDC_PROJECT_ID} pubsub emulator to start"

RETRY_COUNT=0

until $(curl --output /dev/null -s --fail -X GET http://localhost:3334)
do
    if [ "${RETRY_COUNT}" -lt 30 ]; then
        echo sleeping
        ((RETRY_COUNT++))
        sleep 1
    else
        echo "Couldn't connect to PubSub emulator. Exiting."
        exit
    fi

    echo "Waited ${RETRY_COUNT} second(s)"
done

create_topic "${RUSTY_CDC_PROJECT_ID}" "${RUSTY_CDC_TOPIC}"

create_subscription "${RUSTY_CDC_PROJECT_ID}" "${RUSTY_CDC_TOPIC}"

sleep infinity