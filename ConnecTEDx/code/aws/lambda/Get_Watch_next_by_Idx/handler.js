const connect_to_db = require('./db');
const tedx = require('./tedx');

module.exports.Get_Watch_next_by_idx = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;

    let TedId;
    let body = {};

    try {
        if (event.id) {
            TedId = event.id;
        } else if (event.body) {
            body = JSON.parse(event.body);
            if (body.id) {
                TedId = body.id;
            } else {
                throw new Error('Ted ID is missing in the request body');
            }
        } else {
            throw new Error('Ted ID is missing in the request');
        }
    } catch (err) {
        callback(null, {
            statusCode: 400,
            headers: { 'Content-Type': 'text/plain' },
            body: err.message
        });
        return;
    }

    connect_to_db().then(() => {
        tedx.findOne({ _id: TedId })
            .then(talk => {
                if (talk) {
                    callback(null, {
                        statusCode: 200,
                        body: JSON.stringify(talk.related_videos)
                    });
                } else {
                    callback(null, {
                        statusCode: 404,
                        headers: { 'Content-Type': 'text/plain' },
                        body: 'Ted not found.'
                    });
                }
            })
            .catch(err => {
                callback(null, {
                    statusCode: err.statusCode || 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Could not fetch the Ted.'
                });
            });
    }).catch(err => {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Database connection error.'
        });
    });
};