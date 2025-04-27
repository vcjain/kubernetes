#!/bin/bash

# Check if action parameter is passed
if [ $# -lt 1 ]; then
  echo "Usage: $0 {up|down|get-access}"
  exit 1
fi

# Read active project and zone from gcloud config
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
ZONE=${ZONE:-"us-central1-a"}  # Default if zone not set

if [ -z "$PROJECT_ID" ]; then
  echo "No project set in gcloud configuration. Please run:"
  echo "  gcloud config set project <your-project-id>"
  exit 1
fi

# Other settings
ACTION="$1"
CLUSTER_NAME="my-cluster"
CUSTOM_CONTEXT_NAME="my-cluster"
NODE_LABELS="purpose=my-cluster"
MACHINE_TYPE="e2-medium"
NUM_NODES=3

if [ "$ACTION" == "up" ]; then
  echo "Creating GKE cluster in project $PROJECT_ID, zone $ZONE..."

  gcloud container clusters create "$CLUSTER_NAME" \
    --num-nodes="$NUM_NODES" \
    --machine-type="$MACHINE_TYPE" \
    --labels="$NODE_LABELS" \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --tags="my-cluster" \
    --zone="$ZONE" \
    --quiet

  echo "Cluster $CLUSTER_NAME created successfully."

elif [ "$ACTION" == "get-access" ]; then
  echo "Fetching kubeconfig for cluster $CLUSTER_NAME..."

  # Fetch kubeconfig
  gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$ZONE"

  # Get the current context name (default gke_.... format)
  DEFAULT_CONTEXT=$(kubectl config current-context)

  # Rename context to custom name
  echo "Renaming context $DEFAULT_CONTEXT to $CUSTOM_CONTEXT_NAME..."
  kubectl config rename-context "$DEFAULT_CONTEXT" "$CUSTOM_CONTEXT_NAME"

  echo "Access setup complete. Now using context $CUSTOM_CONTEXT_NAME."

elif [ "$ACTION" == "down" ]; then
  echo "Deleting GKE cluster $CLUSTER_NAME in project $PROJECT_ID, zone $ZONE..."

  # Delete cluster
  gcloud container clusters delete "$CLUSTER_NAME" \
    --zone="$ZONE" \
    --quiet

  # Clean up kubeconfig
  echo "Deleting kubeconfig context $CUSTOM_CONTEXT_NAME..."

  kubectl config delete-context "$CUSTOM_CONTEXT_NAME"
  kubectl config unset clusters."$CUSTOM_CONTEXT_NAME"
  kubectl config unset users."$CUSTOM_CONTEXT_NAME"

  echo "Cluster and kubeconfig context deleted successfully."

else
  echo "Invalid action: $ACTION"
  echo "Usage: $0 {up|down|get-access}"
  exit 1
fi
