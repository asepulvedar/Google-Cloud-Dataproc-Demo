# %% Execute the .py file as a Dataproc job
# if the bucket is not created, create it, use a if to ask if the bucket exists
## https://cloud.google.com/dataproc/docs/tutorials/bigquery-connector-spark-example

# create variables for the project and bucketname
export PROJECT_ID=your-project-id
export BUCKET_NAME=your-bucket-id
export CLUSTER_NAME=cluster-scikit-learn-gcs-dependencies-spark
export REGION=us-central1

# if the bucket does not exist, create it
gsutil ls -b gs://$BUCKET_NAME/ || gsutil mb gs://$BUCKET_NAME/

gsutil cp python-scikit-learn-job.py gs://$BUCKET_NAME/python-scikit-learn-writebq-spark-job.py

# copy the init-actions.sh file to the bucket
gsutil cp gs://dataproc-initialization-actions/connectors/connectors.sh gs://$BUCKET_NAME/connectors.sh


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
    --enable-component-gateway \
    --initialization-actions=gs://$BUCKET_NAME/connectors.sh


# Execute the Python file as a Dataproc job and specifying the python dependencies file
gcloud dataproc jobs submit pyspark gs://$BUCKET_NAME/python-scikit-learn-writebq-spark-job.py \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID \
    --py-files=gs://$BUCKET_NAME/dependencies.zip

# Delete the cluster
#gcloud dataproc clusters delete $CLUSTER_NAME --region=$REGION --project=$PROJECT_ID