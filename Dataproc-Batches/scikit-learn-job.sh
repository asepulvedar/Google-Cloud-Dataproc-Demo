# create variables for the project and bucketname
export PROJECT_ID=your-project-id
export BUCKET_NAME=your-bucket-id
export REGION=us-central1

# if the bucket does not exist, create it
gsutil ls -b gs://$BUCKET_NAME/ || gsutil mb gs://$BUCKET_NAME/

gsutil cp ../ScikitLearn-Job/python-scikit-learn-job-writebq-pandas.py gs://$BUCKET_NAME/python-scikit-learn-job-writebq-pandas.py

# Execute the pyspark job as a Dataproc Serverless job
gcloud dataproc batches submit pyspark gs://$BUCKET_NAME/python-scikit-learn-job-writebq-pandas.py.py \
--project=$PROJECT_ID \
--region=$REGION \
--batch=python-scikit-learn-job-writebq-bqapi-demo-serverless-no-spark \
--py-files=gs://$BUCKET_NAME/dependencies.zip