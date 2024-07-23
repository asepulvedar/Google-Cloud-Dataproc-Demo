

# create variables for the project and bucketname
export PROJECT_ID=your-project-id
export BUCKET_NAME=your-bucket-id
export REGION=us-central1

# if the bucket does not exist, create it
gsutil ls -b gs://$BUCKET_NAME/ || gsutil mb gs://$BUCKET_NAME/

gsutil cp ../ScikitLearn-Job/python-scikit-learn-job-writebq-bqapi.py gs://$BUCKET_NAME/python-scikit-learn-job-writebq-bqapi.py

# Execute the pyspark job as a Dataproc Serverless job
gcloud dataproc batches submit pyspark gs://$BUCKET_NAME/python-scikit-learn-job-writebq-bqapi.py \
--project=$PROJECT_ID \
--region=$REGION \
--batch=python-scikit-learn-job-writebq-bqapi-demo-serverless \
--py-files=gs://$BUCKET_NAME/dependencies.zip \
--jars="gs://${BUCKET_NAME}/drivers/spark-3.5-bigquery-0.39.1.jar"


#gcloud dataproc batches submit --project your-project-id --region us-central1 pyspark --batch batch-2a3e gs://your-bucket-id/python-scikit-learn-writebq-spark-job-serverless.py --version 2.2 --jars gs://your-bucket-id/drivers/spark-3.5-bigquery-0.39.1.jar --py-files gs://your-bucket-id/dependencies.zip --subnet default
