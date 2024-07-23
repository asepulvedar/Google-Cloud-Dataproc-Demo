
# create variables for the project and bucketname
export PROJECT_ID=your-project-id
export BUCKET_NAME=your-bucket-id3
export REGION=us-central1
export PYSPARK_FILE=python-sparkml-job.py

# if the bucket does not exist, create it
gsutil ls -b gs://$BUCKET_NAME/ || gsutil mb gs://$BUCKET_NAME/

# copy the python file to the bucket
gsutil cp $PYSPARK_FILE gs://$BUCKET_NAME/$PYSPARK_FILE


# Execute the Python file as a Dataproc Serverless job
gcloud dataproc batches submit pyspark gs://$BUCKET_NAME/$PYSPARK_FILE \
    --region=$REGION \
    --project=$PROJECT_ID \
    --jars=gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.13-0.39.1.jar