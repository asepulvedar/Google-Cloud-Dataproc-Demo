# Configure Docker to use the Google Container Registry
gcloud auth configure-docker

gcloud auth configure-docker \
    us-central1-docker.pkg.dev

# Set the project ID and the image name
export PROJECT_ID=your-project-id
export IMAGE_NAME=us-central1-docker.pkg.dev/$PROJECT_ID/dataproc/dataproc-py-r:latest

# Create the Artifact Registry if not exists
gcloud artifacts repositories create dataproc \
      --repository-format=docker \
      --location=us-central1 \
      --project=$PROJECT_ID

# Download the BigQuery connector.
FILE="spark-bigquery-with-dependencies_2.12-0.22.2.jar"
GCS_URI="gs://spark-lib/bigquery/$FILE"

if [ ! -f "$FILE" ]; then
    gsutil cp "$GCS_URI" .
else
    echo "File $FILE already exists."
fi

# Download the Miniconda3 installer.
wget -nc https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh

# Build the Docker image and tag it with the Google Artifact Registry
docker build -t "${IMAGE_NAME}" .

# Push the Docker image to the Google Artifact Registry
docker push "${IMAGE_NAME}"



# Install r-bigquery packahe in R in path
