const connect_to_db = require('./db');
const Person = require('./Person');

require('dotenv').config({ path: './variables.env' });

module.exports.get_top_tags = async (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));

    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    const { id } = body;

    if (!id) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'ID is required.'
        });
        return;
    }

    try {
        await connect_to_db();
        const person = await Person.findById(id);

        if (!person) {
            callback(null, {
                statusCode: 404,
                headers: { 'Content-Type': 'text/plain' },
                body: 'Person not found.'
            });
            return;
        }
        const totalTagViews = person.tags_viewed.reduce((acc, tag) => acc + tag.tag_count, 0);
        const sortedTags = person.tags_viewed.sort((a, b) => b.tag_count - a.tag_count);
        const topTags = sortedTags.slice(0, 3).map(tag => ({
            tag: tag.tag,
            percentage: ((tag.tag_count / totalTagViews) * 100).toFixed(2) + '%'
        }));

        callback(null, {
            statusCode: 200,
            body: JSON.stringify(topTags)
        });

    } catch (err) {
        console.error('Error:', err);
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch top tags.'
        });
    }
};