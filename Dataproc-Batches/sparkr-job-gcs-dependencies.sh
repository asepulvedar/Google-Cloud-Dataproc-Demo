# Execute a SparkR job on Dataproc
# Usage: ./sparkr-job.sh project-id bucket-name
export PROJECT=your-project-id
export BUCKET=your-bucket-id
export REGION=us-central1

# Copy the SparkR job to the Cloud Storage bucket
gsutil cp ../R-Job/r-ml-job.R gs://${BUCKET}/r-ml-job-pkgs-gcs.R

# Execute the SparkR job in Serverless mode and specify the R dependencies needed bigrquery, dplyr, and ggplot2, randomForest
gcloud dataproc batches submit spark-r gs://${BUCKET}/r-ml-job-pkgs-gcs.R \
    --project=${PROJECT} \
    --region=${REGION} \
    --batch=r-ml-job-pkgs-gcs \
    --deps-bucket=${BUCKET} \
