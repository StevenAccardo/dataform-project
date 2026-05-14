#!/bin/bash
set -e

source .env

echo "Setting up GCP project: $GCP_PROJECT_ID"

echo "Enabling APIs..."
gcloud services enable bigquery.googleapis.com
gcloud services enable dataform.googleapis.com
gcloud services enable secretmanager.googleapis.com

echo "Creating datasets..."
bq mk --dataset --location=$BQ_LOCATION "$GCP_PROJECT_ID:raw"
bq mk --dataset --location=$BQ_LOCATION "$GCP_PROJECT_ID:staging"
bq mk --dataset --location=$BQ_LOCATION "$GCP_PROJECT_ID:marts"

echo "Loading raw data..."
bq cp bigquery-public-data:new_york_taxi_trips.tlc_yellow_trips_2022 "$GCP_PROJECT_ID:raw.tlc_yellow_trips_2022"

echo "Setup complete. Proceed to GCP console to set up Dataform repository."
