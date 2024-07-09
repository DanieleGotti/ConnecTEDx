const mongoose = require('mongoose');

const talk_schema = new mongoose.Schema({
    _id: String,
    title: String,
    url: String,
    description: String,
    speakers: String,
    url_image: String
}, { collection: 'tedx_data' });

module.exports = mongoose.model('talk', talk_schema);