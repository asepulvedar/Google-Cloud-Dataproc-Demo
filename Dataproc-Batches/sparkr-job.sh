# Execute a SparkR job on Dataproc
# Usage: ./sparkr-job.sh project-id bucket-name
export PROJECT=your-project-id
export BUCKET=your-bucket-id
export CLUSTER_NAME=sparkr-cluster
export JOB_NAME=r-ml-job-serverless
export REGION=us-central1

# Copy the SparkR job to the Cloud Storage bucket
gsutil cp ../R-Job/r-ml-job.R gs://${BUCKET}/r-ml-job.R

# Delete SparrkR job if it exists
gcloud dataproc batches delete ${JOB_NAME} --project=${PROJECT} --region=${REGION} --quiet

# Execute the SparkR job in Serverless mode and specify the R dependencies needed bigrquery, dplyr, and ggplot2, randomForest
gcloud dataproc batches submit spark-r gs://${BUCKET}/r-ml-job.R \
    --project=${PROJECT} \
    --region=${REGION} \
    --batch=${JOB_NAME} \
    --deps-bucket=${BUCKET} \
    --network=https://www.googleapis.com/compute/v1/projects/your-project-id/global/networks/default \
