const mongoose = require('mongoose');

const person_schema = new mongoose.Schema({
    _id: String,
    coordinateX: Number,
    coordinateY: Number
}, { collection: 'user_data' });

module.exports = mongoose.model('user_data', person_schema);
