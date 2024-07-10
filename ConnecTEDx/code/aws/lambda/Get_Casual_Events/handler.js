const connect_to_db = require('./db');
const Event = require('./Event'); 

module.exports.get_casual_events = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {}
    if (event.body) {
        body = JSON.parse(event.body);
    }

    if (!body.doc_per_page) {
        body.doc_per_page = 10;
    }
    if (!body.page) {
        body.page = 1;
    }

    connect_to_db().then(() => {
        console.log('=> get_all events');

        Event.aggregate([
            { $sample: { size: body.doc_per_page } }, 
            {
                $project: {
                    name: 1,
                    event_url: 1,
                    img_url: 1,
                    start_date: 1,
                    city: 1,
                    price: 1
                }
            } 
        ])
        .then(events => {
                callback(null, {
                    statusCode: 200,
                    body: JSON.stringify(events)
                });
            }
        )
        .catch(err =>
            callback(null, {
                statusCode: err.statusCode || 500,
                headers: { 'Content-Type': 'text/plain' },
                body: 'Could not fetch the events.'
            })
        );
    });
};
