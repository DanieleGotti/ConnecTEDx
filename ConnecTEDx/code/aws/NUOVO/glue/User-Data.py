###### User-Data
######

import sys
import pyspark
from pyspark.sql.functions import col, collect_list, struct, explode, count
from pyspark.sql import SparkSession
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

### FROM FILES
user_dataset_path = "s3://prog-connectedx-data/user.csv"
user_video_dataset_path = "s3://prog-connectedx-data/user_video.csv"
tags_dataset_path = "s3://prog-connectedx-data/tags.csv"

### READ PARAMETERS
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

### START JOB CONTEXT AND JOB
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

### READ INPUT FILES TO CREATE DATASETS
user_dataset = spark.read \
    .option("header", "true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(user_dataset_path)

user_video_dataset = spark.read \
    .option("header", "true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(user_video_dataset_path)

tags_dataset = spark.read \
    .option("header", "true") \
    .csv(tags_dataset_path)

### PROCESS USER DATASET
user_dataset = user_dataset.withColumn("_id", col("id")).drop("id")

### AGGREGATE VIDEO DATA
user_video_agg = user_video_dataset.groupBy(col("id_user")).agg(
    collect_list(col("id_video")).alias("video_visti")
)

user_video_agg = user_video_agg.select(col("id_user").alias("_id"), "video_visti")

### EXPLODE VIDEO_VISTI TO JOIN WITH TAGS
user_video_exploded = user_video_agg.withColumn("id_video", explode(col("video_visti")))

### JOIN TAGS DATASET WITH EXPLODED VIDEO DATA
tags_with_user = tags_dataset.join(user_video_exploded, tags_dataset.id == user_video_exploded.id_video, "inner")

### COUNT TAGS PER USER
tags_count_per_user = tags_with_user.groupBy(user_video_exploded["_id"], tags_dataset["tag"]).agg(
    count("*").alias("tag_count")
)

### RE-AGGREGATE TO GET THE TAGS AND THEIR COUNTS AS A LIST FOR EACH USER
tags_aggregated = tags_count_per_user.groupBy(col("_id")).agg(
    collect_list(struct(col("tag"), col("tag_count").alias("tag_count"))).alias("tags_viewed")
)

### JOIN USER DATA WITH VIDEO DATA
user_data_full = user_dataset.join(user_video_agg, "_id", "left")

### JOIN WITH AGGREGATED TAGS DATASET
user_data_full = user_data_full.join(tags_aggregated, "_id", "left")

### CONVERT TO DYNAMIC FRAME AND WRITE TO MONGODB
write_mongo_options = {
    "connectionName": "CONNECTEDX_Connection",
    "database": "connectedx_database",
    "collection": "user_data",
    "ssl": "true",
    "ssl.domain_match": "false"
}

user_data_dynamic_frame = DynamicFrame.fromDF(user_data_full, glueContext, "nested")

glueContext.write_dynamic_frame.from_options(user_data_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)

job.commit()