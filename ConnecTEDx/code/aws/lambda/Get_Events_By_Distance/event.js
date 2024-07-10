const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
    _id: String,
    name : String,
    event_url : String,
    img_url : String,
    start_date : String,
    price : String,
    city : String,
    longitude: Number,
    latitude: Number,
}, { collection: 'event_data' });

module.exports = mongoose.model('Event', eventSchema);
