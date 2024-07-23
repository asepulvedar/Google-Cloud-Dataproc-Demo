# Link: https://medium.com/@ln.yeshwanth/installing-the-python-packages-on-dataproc-serverless-pyspark-e02b5798c470

# Run on a Linux Machine

# create variables for the project and bucketname
export BUCKET_NAME=your-bucket-id

# create a create an utils folder and install the python packages
mkdir utils
# pip install -r requirements.txt -t=dependencies/
pip3 install scikit-learn==1.4.2 pandas==2.2.2 numpy==1.26.4 pandas-gbq==0.23.1 google-cloud-bigquery==3.25.0 --target=utils/

# Zip up all the required dependencies
zip -r dependencies.zip utils

# Upload the zip file to GCS
gsutil cp dependencies.zip gs://$BUCKET_NAME/


