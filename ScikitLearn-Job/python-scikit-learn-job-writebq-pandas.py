# %% Create a ML Regression Model that reads data from BigQuery and trains a model using scikit-learn and write te results to a BigQuery Tables
from google.cloud import bigquery
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split

# %% Set up the parameters
project_id = 'your-project-id'
dataset_id = 'ml_demos'
dataset_location = 'US'
destination_table_id = 'penguins_body_mass_predictions'
bigquery_destination_table = f'{project_id}.{dataset_id}.{destination_table_id}'

# %% Initialize a BigQuery client
client = bigquery.Client(
    project=project_id
)

# %% Create the dataset if it does not exist
try:
    client.get_dataset(f"{project_id}.{dataset_id}")
except:
    dataset = bigquery.Dataset(f"{project_id}.{dataset_id}")
    dataset.location = dataset_location
    dataset = client.create_dataset(dataset)
    print(f"Dataset {dataset.dataset_id} created.")

# %% Define your SQL query
query = """
SELECT
  *
FROM
  `bigquery-public-data.ml_datasets.penguins`
WHERE
  body_mass_g IS NOT NULL;
"""

# Run the query and convert to a pandas DataFrame
df = client.query(query).to_dataframe()

# Example preprocessing: fill missing values
df.fillna(0, inplace=True)

# %% Feature Engineering

# features engineering function
def feature_engineering(df):
    # create a one-hot encoding of the species column
    df = pd.get_dummies(df, columns=['species'],
                        drop_first=True)

    # create a one-hot encoding of the island column
    df = pd.get_dummies(df, columns=['island'],
                        drop_first=True)

    # remove unnecessary columns
    df.drop(['sex'], axis=1, inplace=True)
    return df

# create a one-hot encoding of the island column
df_features = feature_engineering(df)



# %% Split data into features and target
X = df_features.drop('body_mass_g', axis=1)
y = df_features['body_mass_g']

# Split data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# %%  Initialize and train the regression model
model = RandomForestRegressor(n_estimators=100, random_state=42,n_jobs=2)
model.fit(X_train, y_train)

# %% Make predictions and evaluate the model
predictions = model.predict(X_test)
mse = mean_squared_error(y_test, predictions)
print(f"Mean Squared Error: {mse}")

# Convert predictions to a BigQuery DataFrame

results_df = pd.DataFrame(predictions, columns=['predictions'])
# Add the test data to the results DataFrame
results_df['body_mass_g'] = y_test.values

# Add the features to the results DataFrame
results_df = pd.concat([results_df, X_test.reset_index(drop=True)], axis=1)


# %%Write the DataFrame to BigQuery using the to_gbq() method
results_df.to_gbq(bigquery_destination_table,
                  project_id=project_id,
                  progress_bar=True,
                  if_exists='replace')