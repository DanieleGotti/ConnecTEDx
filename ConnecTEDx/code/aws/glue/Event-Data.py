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
events_dataset_path = "s3://prog-connectedx-data/events.csv"

### LEGGI I PARAMETRI PASSATI ALLO SCRIPT
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

### INIZIALIZZO IL CONTESTO DI LAVORO GLUE E SPARK
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'])

### LEGGO IL FILE CSV PER CREARE IL DATASET DI INPUT
events_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(events_dataset_path)

### STAMPO LO SCHEMA DEL DATASET
events_dataset.printSchema()

### CONVERTE IN DYNAMICFRAME E SCRIVI IN MONGODB
write_mongo_options = {
    "connectionName": "CONNECTEDX_Connection",
    "database": "connectedx_database",
    "collection": "event_data",
    "ssl": "true",
    "ssl.domain_match": "false"
}

### CONVERTE IN DYNAMICFRAME
events_dynamic_frame = DynamicFrame.fromDF(events_dataset, glueContext, "nested")

### SCRIVO IN MONGODB UTILIZZANDO LE OPZIONI SPECIFICATE
glueContext.write_dynamic_frame.from_options(events_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)

### TERMINA IL JOB
job.commit()
