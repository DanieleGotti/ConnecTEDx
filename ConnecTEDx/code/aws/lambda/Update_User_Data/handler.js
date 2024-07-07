const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { MongoClient } = require('mongodb');
const { ObjectId } = require('mongodb');

const mongoUri = "mongodb+srv://danielegotti:dGiD21!69$@mycluster962.ijhfwwk.mongodb.net/";
const bucketName = 'tedxdatagotti';

const s3Client = new S3Client({ region: 'us-east-1' });

exports.update_user = async (event) => {
    const { _id, name, surname, position, coordinateX, coordinateY, email, password, url_user_img } = JSON.parse(event.body);

    try {
        // Connect to MongoDB
        const client = new MongoClient(mongoUri);
        await client.connect();
        const db = client.db('unibg_tedx_2024');
        const collection = db.collection('user_data');

        // Prepare update object
        const updateObj = {};
        if (name) updateObj.name = name;
        if (surname) updateObj.surname = surname;
        if (position) updateObj.position = position;
        if (coordinateX) updateObj.coordinateX = coordinateX;
        if (coordinateY) updateObj.coordinateY = coordinateY;
        if (email) updateObj.email = email;
        if (password) updateObj.password = password;
        if (url_user_img) updateObj.url_user_img = url_user_img;

        // Update MongoDB document
        await collection.updateOne({ _id: new ObjectId(_id) }, { $set: updateObj });

        // Prepare CSV data (assuming you are converting updateObj to CSV format)
        const csvData = `${_id},${name},${surname},${position},${coordinateX},${coordinateY},${email},${password},${url_user_img}\n`;

        // Update S3 object
        await s3Client.send(new PutObjectCommand({
            Bucket: bucketName,
            Key: 'user.csv',
            Body: csvData,
            ContentType: 'text/csv'
        }));

        await client.close();

        return {
            statusCode: 200,
            body: JSON.stringify('Profilo aggiornato con successo')
        };
    } catch (err) {
        console.error('Errore durante l\'aggiornamento del profilo:', err);
        return {
            statusCode: 500,
            body: JSON.stringify('Errore durante l\'aggiornamento del profilo')
        };
    }
};
