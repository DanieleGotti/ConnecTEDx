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

### DAI FILE
user_dataset_path = "s3://prog-connectedx-data/user.csv"
user_video_dataset_path = "s3://prog-connectedx-data/user_video.csv"
tags_dataset_path = "s3://prog-connectedx-data/tags.csv"

### LEGGO I PARAMETRI
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

### INIZIALIZZO IL JOB
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

### LEGGO I DATI
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

### PROCESSO I DATI
user_dataset = user_dataset.withColumn("_id", col("id")).drop("id")

### AGGREGO I DATI VIDEO
user_video_agg = user_video_dataset.groupBy(col("id_user")).agg(
    collect_list(col("id_video")).alias("video_visti")
)

user_video_agg = user_video_agg.select(col("id_user").alias("_id"), "video_visti")

### "ESPLODO" VIDEO_VISTI PER FARE IL JOIN CON I TAG
user_video_exploded = user_video_agg.withColumn("id_video", explode(col("video_visti")))

### JOIN TRA TAGS DATASET CON VIDEO DATA "ESPLOSI"
tags_with_user = tags_dataset.join(user_video_exploded, tags_dataset.id == user_video_exploded.id_video, "inner")

### FACCIO LA CONTA DEI TAGS PER USER
tags_count_per_user = tags_with_user.groupBy(user_video_exploded["_id"], tags_dataset["tag"]).agg(
    count("*").alias("tag_count")
)

### RI-AGGREGO IL TUTTO PER PRENDERE I TAGS E LA LORO CONTA
tags_aggregated = tags_count_per_user.groupBy(col("_id")).agg(
    collect_list(struct(col("tag"), col("tag_count").alias("tag_count"))).alias("tags_viewed")
)

### JOIN USER DATA CON VIDEO DATA
user_data_full = user_dataset.join(user_video_agg, "_id", "left")

### JOIN CON AGGREGATED TAGS DATASET
user_data_full = user_data_full.join(tags_aggregated, "_id", "left")

### CONVERTO A DYNAMIC FRAME E SCRIVO
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
