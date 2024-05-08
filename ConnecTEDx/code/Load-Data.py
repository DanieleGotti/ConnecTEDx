###### Load_Data
######

import sys
import json
import pyspark
from pyspark.sql.functions import col, collect_list, array_join

from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job


### FROM FILES
tedx_dataset_path = "s3://tedxdatagotti/final_list.csv"

### READ PARAMETERS
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

### START JOB CONTEXT AND JOB
sc = SparkContext()

glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)


### READ INPUT FILES TO CREATE AN INPUT DATASET
tedx_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(tedx_dataset_path)
   
tedx_dataset.printSchema()


## READ THE DETAILS
details_dataset_path = "s3://tedxdatagotti/details.csv"
details_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(details_dataset_path)

details_dataset = details_dataset.select(col("id").alias("id_ref"),
                                         col("description"),
                                         col("duration"),
                                         col("publishedAt"))
                                         
                                         
## READ THE IMAGES (VERSIONE NUOVA)
images_dataset_path = "s3://tedxdatagotti/images.csv"
images_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(images_dataset_path)

images_dataset = images_dataset.select(col("id").alias("id_ref"),
                                         col("url").alias("url_image"))

# AND JOIN WITH THE MAIN TABLE
tedx_dataset_main = tedx_dataset.join(details_dataset, tedx_dataset.id == details_dataset.id_ref, "left") \
    .drop("id_ref")
   
#VERSIONE NUOVA DEL JOIN
tedx_dataset_main = tedx_dataset_main.join(images_dataset, tedx_dataset_main.id == images_dataset.id_ref, "left") \
    .drop("id_ref")



# JOB ADD WATCH NEXT:
## LETTURA DEI DATI DALLA TABELLA "related_videos.csv" + JOIN AL DATASET MAIN DEI WATCH-NEXT

#   1. Collego l'URI S3 dei dati che si trovano nel bucket
watch_next_dataset_path = "s3://tedxdatagotti/related_videos.csv"

#   2. Leggo i dati dal csv usando option per gestire la lettura su diverse righe
watch_next_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(watch_next_dataset_path)      

# 3. Seleziona le colonne utili all'app dalla tabella dei video collegati
watch_next_dataset = watch_next_dataset.groupBy(col("id").alias("id_ref")).agg(
    collect_list("related_id").alias("id_rel"),
    collect_list("title").alias("title_rel"),
    collect_list("presenterDisplayName").alias("presenter_rel"))

# 4. Svolge il join tra il dataset principale e il nuovo watch_next_dataset
tedx_dataset_main = tedx_dataset_main.join(watch_next_dataset, tedx_dataset_main.id == watch_next_dataset.id_ref, "left") \
    .drop("id_ref")

tedx_dataset_main.printSchema()



## READ TAGS DATASET
tags_dataset_path = "s3://tedxdatagotti/tags.csv"
tags_dataset = spark.read.option("header","true").csv(tags_dataset_path)


# CREATE THE AGGREGATE MODEL, ADD TAGS TO TEDX_DATASET
tags_dataset_agg = tags_dataset.groupBy(col("id").alias("id_ref")).agg(collect_list("tag").alias("tags"))
tags_dataset_agg.printSchema()
tedx_dataset_agg = tedx_dataset_main.join(tags_dataset_agg, tedx_dataset.id == tags_dataset_agg.id_ref, "left") \
    .drop("id_ref") \
    .select(col("id").alias("_id"), col("*")) \
    .drop("id") \

tedx_dataset_agg.printSchema()



write_mongo_options = {
    "connectionName": "TEDX2024",
    "database": "unibg_tedx_2024",
    "collection": "tedx_data",
    "ssl": "true",
    "ssl.domain_match": "false"}
from awsglue.dynamicframe import DynamicFrame
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(tedx_dataset_agg, glueContext, "nested")

glueContext.write_dynamic_frame.from_options(tedx_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)