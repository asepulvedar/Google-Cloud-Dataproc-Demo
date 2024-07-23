# Kmens Clustering iris data with NbClust, writing the final table to BigQuery

library('NbClust')
library('factoextra')
library('dplyr')
library('bigrquery')

# Set up the parameters
project_id <- 'your-project-id'
dataset_id <- 'ml_demos'
dataset_location <- 'US'
# Table with the Results
destination_table_results_id <- 'usarrest_kmeans_clusters_results'
bigquery_destination_table_results <- paste(project_id,
                                            dataset_id,
                                            destination_table_results_id,
                                            sep = ".")
# Table with Cluster details
destination_table_id <- 'usarrest_kmeans_clusters'
bigquery_destination_table_clusters <- paste(project_id,
                                             dataset_id,
                                             destination_table_id,
                                             sep = ".")

# Load the data

# Standardize the data
df <- scale(USArrests)
head(df)


# Elbow method
fviz_nbclust(df, kmeans, method = "wss") +
    geom_vline(xintercept = 4, linetype = 2)+
  labs(subtitle = "Elbow method")


# Silhouette method
fviz_nbclust(df, kmeans, method = "silhouette")+
  labs(subtitle = "Silhouette method")

# Gap statistic
# nboot = 50 to keep the function speedy.
# recommended value: nboot= 500 for your analysis.
# Use verbose = FALSE to hide computing progression.
set.seed(123)
fviz_nbclust(df, kmeans, nstart = 25,  method = "gap_stat", nboot = 50)+
  labs(subtitle = "Gap statistic method")


# Compute k-means with k = 4
set.seed(123)
km.res <- kmeans(df, 4)

# Visualize k-means clusters
fviz_cluster(km.res, data = df)

# Save the results to BigQuery
# Add the cluster column to the original data

df_results <- cbind(USArrests, cluster = km.res$cluster)

df_cluster_details <- as.data.frame(km.res$centers)

# Write the results to BigQuery
bq_table_upload(bigquery_destination_table_results,
                df_results,
                write_disposition = "WRITE_TRUNCATE")

# Write the cluster details to BigQuery
bq_table_upload(bigquery_destination_table_clusters,
                df_cluster_details,
                write_disposition = "WRITE_TRUNCATE")
