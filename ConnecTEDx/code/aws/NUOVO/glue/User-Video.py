###### User-Video
######

import sys
import pyspark
from pyspark.sql.functions import col, collect_list
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

### PERCORSO DEL FILE S3 DA DOVE LEGGERE I DATI
user_video_dataset_path = "s3://prog-connectedx-data/user_video.csv"

### LEGGI I PARAMETRI PASSATI ALLO SCRIPT
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

### INIZIALIZZO IL CONTESTO DI LAVORO GLUE E SPARK
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'])

### LEGGO IL FILE CSV PER CREARE IL DATASET DI INPUT
user_video_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(user_video_dataset_path)

### STAMPO LO SCHEMA DEL DATASET
user_video_dataset.printSchema()

### AGGREGO I DATI PER id_user
user_video_agg = user_video_dataset.groupBy(col("id_user")).agg(
    collect_list(col("id_video")).alias("video_visti")
)

### SELEZIONO SOLO LE COLONNE id_user E video_visti
user_video_agg = user_video_agg.select(col("id_user").alias("_id"), "video_visti")

### STAMPA LO SCHEMA DEL DATASET AGGREGATO
user_video_agg.printSchema()

### CONVERTE IN DYNAMICFRAME E SCRIVI IN MONGODB
write_mongo_options = {
    "connectionName": "CONNECTEDX_Connection",
    "database": "connectedx_database",
    "collection": "user_video",
    "ssl": "true",
    "ssl.domain_match": "false"
}

# CONVERTE IN DYNAMICFRAME
user_video_dynamic_frame = DynamicFrame.fromDF(user_video_agg, glueContext, "nested")

# SCRIVO IN MONGODB UTILIZZANDO LE OPZIONI SPECIFICATE
glueContext.write_dynamic_frame.from_options(user_video_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)
