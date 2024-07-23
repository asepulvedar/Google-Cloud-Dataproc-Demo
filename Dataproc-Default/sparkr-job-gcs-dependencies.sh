# Execute a SparkR job on Dataproc
# Usage: ./sparkr-job.sh project-id bucket-name
export PROJECT=your-project-id
export BUCKET=your-bucket-id
export REGION=us-central1
export CLUSTER_NAME=cluster-sparkr

# Copy the SparkR job to the Cloud Storage bucket
gsutil cp ../R-Job/r-ml-job.R gs://${BUCKET}/r-ml-job-pkgs-gcs.R

# Ask using a IF and if the Dataproc cluster exists, if it does not exist, create it and install this python component pandas_gbq in the cluster
# if the cluster does not exist, create it
gcloud dataproc clusters list --region=$REGION | grep $CLUSTER_NAME || gcloud dataproc clusters create $CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID \
    --single-node \
    --master-machine-type=n1-standard-2 \
    --master-boot-disk-size=500GB \
    --image-version=1.5-debian10 \
    --optional-components=ANACONDA,JUPYTER \
    --enable-component-gateway

# Execute the SparkR job in Serverless mode and specify the R dependencies needed bigrquery, dplyr, and ggplot2, randomForest
gcloud dataproc jobs submit spark-r gs://${BUCKET}/r-ml-job-pkgs-gcs.R \
    --project=${PROJECT} \
    --region=${REGION} \
    --cluster=${CLUSTER_NAME} \
    --bucket=${BUCKET} \
