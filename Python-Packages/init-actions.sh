#!/bin/bash
sudo apt-get update
sudo apt-get install -y python3-pip
pip3 install scikit-learn==1.4.2 pandas==2.2.2 numpy==1.26.4 pandas-gbq==0.23.1 google-cloud-bigquery==3.25.0
