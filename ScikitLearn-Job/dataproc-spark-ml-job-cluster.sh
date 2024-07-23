
# create variables for the project and bucketname
export PROJECT_ID=your-project-id
export BUCKET_NAME=your-bucket-id3
export CLUSTER_NAME=cluster-spark-ml
export REGION=us-central1
export PYSPARK_FILE=python-sparkml-job.py

# if the bucket does not exist, create it
gsutil ls -b gs://$BUCKET_NAME/ || gsutil mb gs://$BUCKET_NAME/

# copy the python file to the bucket
gsutil cp $PYSPARK_FILE gs://$BUCKET_NAME/$PYSPARK_FILE

## Ask using a IF and if the Dataproc cluster exists, if it does not exist, create it and install this python component pandas_gbq in the cluster
gcloud dataproc clusters list --region=$REGION | grep $CLUSTER_NAME || gcloud dataproc clusters create $CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID \
    --single-node \
    --master-machine-type=n1-standard-2 \
    --master-boot-disk-size=500GB \
    --image-version=1.5-debian10 \
    --optional-components=ANACONDA,JUPYTER \
    --enable-component-gateway \
    #--properties=^#^spark:spark.jars.packages=com.google.cloud.spark:spark-bigquery-with-dependencies

# Create the Dataproc cluster with the Spark-BigQuery connector properly included
gcloud dataproc clusters create $CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID \
    --single-node \
    --master-machine-type=n1-standard-2 \
    --master-boot-disk-size=500GB \
    --image-version=1.5-debian10 \
    --optional-components=ANACONDA,JUPYTER \
    --enable-component-gateway \
    --properties=spark:spark.jars.packages=com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.21.1

# Execute the Python file as a Dataproc job in a Cluster with the correct dependencies
gcloud dataproc jobs submit pyspark gs://$BUCKET_NAME/$PYSPARK_FILE \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID \
    --properties=spark.jars.packages=com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.21.1