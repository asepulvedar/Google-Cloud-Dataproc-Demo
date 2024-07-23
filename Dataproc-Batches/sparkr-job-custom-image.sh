# Execute a SparkR job on Dataproc
export PROJECT_ID=your-project-id
export BUCKET=your-bucket-id
export CLUSTER_NAME=sparkr-cluster
export REGION=us-central1
export JOB_NAME=r-ml-job-serverless-custom-image
export DATAPROC_IMAGE=us-central1-docker.pkg.dev/${PROJECT_ID}/dataproc/dataproc-r:latest
export R_FILE=sparkr-job-clustering-custom-image.R

# Copy the SparkR job to the Cloud Storage bucket
gsutil cp ../R-Job/${R_FILE} gs://${BUCKET}/${R_FILE}

# Delete SparrkR job if it exists
gcloud dataproc batches delete ${JOB_NAME} --project=${PROJECT_ID} --region=${REGION} --quiet

# Execute the SparkR job in Serverless mode and specify the R dependencies needed bigrquery, dplyr, and ggplot2, randomForest
gcloud dataproc batches submit spark-r gs://${BUCKET}/${R_FILE} \
    --project=${PROJECT_ID} \
    --region=${REGION} \
    --batch=${JOB_NAME} \
    --container-image=${DATAPROC_IMAGE} \
    --deps-bucket=${BUCKET} \
    --network=https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/networks/default

echo "waiting for the job ..."
gcloud dataproc batches wait ${JOB_NAME} --project=${PROJECT_ID} --region=${REGION}

STATUS=$(gcloud dataproc batches describe ${JOB_NAME}  --project=${PROJECT_ID} --region=${REGION} --format='value(STATE)')
echo "Job Status : ${STATUS}"

if [[ ${STATUS} == "FAILED" ]]; then
  echo "Job ${JOB_NAME} failed." >> ${JOB_NAME}.log
  exit 1
else
  echo "Job ${JOB_NAME} succeeded." >> ${JOB_NAME}.log
  exit 0
fi
