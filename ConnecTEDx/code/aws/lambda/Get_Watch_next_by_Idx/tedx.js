const mongoose = require('mongoose');

const related_video_schema = new mongoose.Schema({
    id: String,
    title: String,
    presenter: String,
});

const talk_schema = new mongoose.Schema({
    _id: String,
    related_videos: [related_video_schema]
}, { collection: 'tedx_data' });

module.exports = mongoose.model('talk', talk_schema);
