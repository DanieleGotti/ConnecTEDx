const mongoose = require('mongoose');

const user_schema = new mongoose.Schema({
    _id: String,
    name: String,
    surname: String,
    position: String,
    email: String,
    password: String,
    url_user_img: String
}, { collection: 'user_data' });

module.exports = mongoose.model('user', user_schema);