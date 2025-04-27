#!/bin/bash

# Check if both parameters are passed
if [ $# -lt 2 ]; then
  echo "Usage: $0 <PROJECT_ID> {up|down}"
  exit 1
fi

# Input parameters
PROJECT_ID="$1"
ACTION="$2"

# Other configurations
CLUSTER_NAME="cluster1"
ZONE="us-central1-a"                     # Change if needed
NODE_LABELS="purpose=gke-testing"
MACHINE_TYPE="e2-medium"                 # Change if needed
NUM_NODES=3

if [ "$ACTION" == "up" ]; then
  echo "Creating GKE cluster in project $PROJECT_ID..."

  gcloud container clusters create "$CLUSTER_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --num-nodes="$NUM_NODES" \
    --machine-type="$MACHINE_TYPE" \
    --labels="$NODE_LABELS" \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --tags="gke-testing" \
    --quiet

  echo "Cluster $CLUSTER_NAME created successfully."

elif [ "$ACTION" == "down" ]; then
  echo "Deleting GKE cluster in project $PROJECT_ID..."

  gcloud container clusters delete "$CLUSTER_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --quiet

  echo "Cluster $CLUSTER_NAME deleted successfully."

else
  echo "Invalid action: $ACTION"
  echo "Usage: $0 <PROJECT_ID> {up|down}"
  exit 1
fi
