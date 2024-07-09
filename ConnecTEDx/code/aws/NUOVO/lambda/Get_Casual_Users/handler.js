//handler
const connect_to_db = require('./db');
const user = require('./User');

module.exports.get_casual_users = (event, context, callback) => {
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
        console.log('=> get_all users');

        // Aggregazione per ottenere documenti casuali e proiettare solo i campi richiesti
        user.aggregate([
            { $sample: { size: body.doc_per_page } }, // Prende un campione casuale di doc_per_page documenti
            {
                $project: {
                    _id: 1,
                    name: 1,
                    surname: 1,
                    position: 1,
                    url_user_img: 1
                }
            } // Proietta solo i campi richiesti
        ])
        .then(users => {
                callback(null, {
                    statusCode: 200,
                    body: JSON.stringify(users)
                });
            }
        )
        .catch(err =>
            callback(null, {
                statusCode: err.statusCode || 500,
                headers: { 'Content-Type': 'text/plain' },
                body: 'Could not fetch the users.'
            })
        );
    });
};