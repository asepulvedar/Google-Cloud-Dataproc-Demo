# %% Execute the .py file as a Dataproc job
# if the bucket is not created, create it, use a if to ask if the bucket exists

# create variables for the project and bucketname
export PROJECT_ID=your-project-id
export BUCKET_NAME=your-bucket-id
export CLUSTER_NAME=cluster-scikit-learn
export REGION=us-central1

# if the bucket does not exist, create it
gsutil ls -b gs://$BUCKET_NAME/ || gsutil mb gs://$BUCKET_NAME/

gsutil cp python-scikit-learn-job.py gs://$BUCKET_NAME/python-scikit-learn-job.py


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
    --properties=^#^dataproc:conda.packages='visions==0.7.1'#dataproc:pip.packages='scikit-learn==1.4.2,pandas==2.2.2,scipy==1.3.1,numpy==1.26.4,pandas-gbq==0.23.1,google-cloud-bigquery==3.25.0' \
    --enable-component-gateway

# Exectue the Python file as a Dataproc job and specify the job name

gcloud dataproc jobs submit pyspark gs://$BUCKET_NAME/python-scikit-learn-job.py \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID

# Delete the cluster
#gcloud dataproc clusters delete $CLUSTER_NAME --region=$REGION --project=$PROJECT_ID