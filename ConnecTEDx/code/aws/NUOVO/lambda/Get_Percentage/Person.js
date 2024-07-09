const mongoose = require('mongoose');

const person_schema = new mongoose.Schema({
    _id: String,
    tags_viewed: [{
        tag: String,
        tag_count: Number
    }]
}, { collection: 'user_data' });

module.exports = mongoose.model('user_data', person_schema);