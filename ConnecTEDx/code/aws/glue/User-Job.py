###### User_Job
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
user_dataset_path = "s3://tedxdatagotti/user.csv"

### READ PARAMETERS
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

### START JOB CONTEXT AND JOB
sc = SparkContext()

glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)


### READ INPUT FILES TO CREATE AN INPUT DATASET
user_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(user_dataset_path)

user_dataset = user_dataset.withColumn("_id", col("id")).drop("id")
                                      
user_dataset.printSchema()



write_mongo_options = {
    "connectionName": "TEDX2024",
    "database": "unibg_tedx_2024",
    "collection": "user_data",
    "ssl": "true",
    "ssl.domain_match": "false"}
from awsglue.dynamicframe import DynamicFrame
user_dataset_dynamic_frame = DynamicFrame.fromDF(user_dataset, glueContext, "nested")

glueContext.write_dynamic_frame.from_options(user_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)