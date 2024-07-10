const connect_to_db = require('./db');
const User = require('./User');

module.exports.get_user_by_id = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;

    let userId;
    let body = {};

    try {
        if (event.id) {
            userId = event.id;
        } else if (event.body) {
            body = JSON.parse(event.body);
            if (body.id) {
                userId = body.id;
            } else {
                throw new Error('User ID is missing in the request body');
            }
        } else {
            throw new Error('User ID is missing in the request');
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
        User.findOne({ _id: userId })
            .then(user => {
                if (user) {
                    callback(null, {
                        statusCode: 200,
                        body: JSON.stringify(user)
                    });
                } else {
                    callback(null, {
                        statusCode: 404,
                        headers: { 'Content-Type': 'text/plain' },
                        body: 'User not found.'
                    });
                }
            })
            .catch(err => {
                callback(null, {
                    statusCode: err.statusCode || 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Could not fetch the user.'
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
