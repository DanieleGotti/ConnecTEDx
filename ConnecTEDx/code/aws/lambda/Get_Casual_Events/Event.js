const mongoose = require('mongoose');

const event_schema = new mongoose.Schema({
    _id: String,
    name: String,
    event_url: String,
    img_url: String,
    start_date: String,
    city: String,
    price: String
}, { collection: 'event_data' });

module.exports = mongoose.model('event', event_schema);