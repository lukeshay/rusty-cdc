#!/bin/bash

gcloud pubsub topics create rusty-cdc --project rusty-cdc-lcl
gcloud pubsub subscriptions create rusty-cdc-subscription --topic rusty-cdc --project rusty-cdc-lcl
