const mongoose = require('mongoose');

const personSchema = new mongoose.Schema({
    _id: String,
    coordinateX: Number,
    coordinateY: Number
}, { collection: 'user_data' });

module.exports = mongoose.model('Person', personSchema);