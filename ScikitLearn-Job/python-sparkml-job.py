from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when
from pyspark.ml.feature import StringIndexer, OneHotEncoder, VectorAssembler
from pyspark.ml import Pipeline
from pyspark.ml.regression import RandomForestRegressor
from pyspark.ml.evaluation import RegressionEvaluator

# %% Set up the parameters
project_id = 'your-project-id'
dataset_id = 'ml_demos'
dataset_location = 'US'
destination_table_id = 'penguins_body_mass_predictions_spark_ml'
bigquery_destination_table = f'{dataset_id}.{destination_table_id}'
bucket_id = 'lake-gc-demo'

# %% Initialize Spark session with BigQuery support
spark = SparkSession.builder \
    .master("yarn") \
    .appName("Spark ML with BigQuery") \
    .getOrCreate()

# %% Read data from BigQuery
df = spark.read.format('bigquery') \
    .option('table', f'{project_id}:ml_demos.penguins') \
    .load()

# %% Filter rows where body_mass_g is not null
df = df.filter(df.body_mass_g.isNotNull())

# %% Feature Engineering
# Indexing species and island columns
speciesIndexer = StringIndexer(inputCol="species", outputCol="speciesIndex")
islandIndexer = StringIndexer(inputCol="island", outputCol="islandIndex")

# One-hot encoding for species and island
speciesEncoder = OneHotEncoder(inputCol="speciesIndex", outputCol="speciesVec")
islandEncoder = OneHotEncoder(inputCol="islandIndex", outputCol="islandVec")

# Assemble features
assembler = VectorAssembler(inputCols=["speciesVec", "islandVec", "culmen_length_mm", "culmen_depth_mm", "flipper_length_mm"],
                            outputCol="features")

# Pipeline
pipeline = Pipeline(stages=[speciesIndexer, islandIndexer, speciesEncoder, islandEncoder, assembler])

# Apply transformations
df_transformed = pipeline.fit(df).transform(df)

# Split data
(train, test) = df_transformed.randomSplit([0.8, 0.2])

# %% Define the model
rf = RandomForestRegressor(featuresCol="features", labelCol="body_mass_g")

# Train the model
model = rf.fit(train)

# Make predictions
predictions = model.transform(test)

# %% Evaluate the model
evaluator = RegressionEvaluator(labelCol="body_mass_g", predictionCol="prediction", metricName="rmse")
rmse = evaluator.evaluate(predictions)
print(f"Root Mean Squared Error (RMSE) on test data = {rmse}")

# Select (prediction, true label) and compute test error
predictions = predictions.withColumnRenamed("prediction", "predictions")

# %% Write the predictions to BigQuery
spark.conf.set('temporaryGcsBucket', bucket_id)

predictions.write.format('bigquery') \
    .option('table', bigquery_destination_table) \
    .mode('overwrite') \
    .save()

# Stop the Spark session
spark.stop()