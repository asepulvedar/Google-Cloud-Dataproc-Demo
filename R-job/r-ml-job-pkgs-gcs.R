require("SparkR")
sparkR.session()

# Install the required packages from MiniCRAN Repo on GCS
install.packages("bigrquery",repos = "https://storage.cloud.google.com/your-bucket-id/miniCRAN/", type = "source")
install.packages("dplyr",repos = "https://storage.cloud.google.com/your-bucket-id/miniCRAN/", type = "source")
install.packages("randomForest",repos = "https://storage.cloud.google.com/your-bucket-id/miniCRAN/", type = "source")

library("dplyr")
library("tidyr")
library("bigrquery")
library("randomForest")

# Set up the parameters
project_id <- 'your-project-id'
dataset_id <- 'ml_demos'
dataset_location <- 'US'
destination_table_id <- 'penguins_body_mass_predictions_with_r'
bigquery_destination_table <- paste(project_id, dataset_id, destination_table_id, sep = ".")

# Authenticate and set the project
#bq_auth(path = "/path/to/your/service-account-file.json")

# Define your SQL query
query <- "
SELECT
  culmen_length_mm,
  culmen_depth_mm,
  flipper_length_mm,
  body_mass_g,
FROM
  `bigquery-public-data.ml_datasets.penguins`
WHERE
  body_mass_g IS NOT NULL;
"

# Run the query and convert to a dataframe
df <- bq_project_query(project_id, query) %>%
  bq_table_download()

# Preprocess data: fill missing values
df[is.na(df)] <- 0

# Feature Engineering
feature_engineering <- function(df) {
  # Replace NA with 0 after pivot_wider, for numeric columns only
  numeric_columns <- sapply(df, is.numeric)
  df[, numeric_columns] <- replace(df[, numeric_columns], is.na(df[, numeric_columns]), 0)

  return(df)
}

# Apply the feature engineering function to your data
df_features <- feature_engineering(df)

# Split data into features and target
target_column <- "body_mass_g"
X <- df_features[, !(names(df_features) %in% target_column)]
y <- df_features[[target_column]]

# Split data into training and testing sets
set.seed(42)
train_indices <- sample(1:nrow(df_features), size = 0.8 * nrow(df_features))
X_train <- X[train_indices, ]
y_train <- y[train_indices]
X_test <- X[-train_indices, ]
y_test <- y[-train_indices]

# Initialize and train the regression model
model <- randomForest(x = X_train, y = y_train, ntree = 100)

# Make predictions and evaluate the model
predictions <- predict(model, X_test)
mse <- mean((predictions - y_test)^2)
cat("Mean Squared Error:", mse, "\n")

# Prepare the data for BigQuery
results_df <- data.frame(predictions = predictions, body_mass_g = y_test, X_test)

# Write the DataFrame to BigQuery
bq_table_upload(bigquery_destination_table,
                results_df,
                write_disposition = "WRITE_TRUNCATE")