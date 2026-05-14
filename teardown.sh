#!/bin/bash
set -e

source .env

echo "WARNING: This will delete all datasets and resources in $GCP_PROJECT_ID"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Teardown cancelled."
  exit 0
fi

echo "Deleting datasets..."
bq rm -r -f $GCP_PROJECT_ID:raw
bq rm -r -f $GCP_PROJECT_ID:staging
bq rm -r -f $GCP_PROJECT_ID:marts

echo "Teardown complete."
