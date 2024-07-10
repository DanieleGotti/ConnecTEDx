
const connect_to_db = require('./db');
const Person = require('./Person');
const Event = require('./event');

require('dotenv').config({ path: './variables.env' });

// Funzione per calcolare la distanza usando la formula di Haversine in metri
function haversine(lat1, lon1, lat2, lon2) {
    function toRad(x) {
        return x * Math.PI / 180;
    }

    const R = 6371000; // Raggio della Terra in metri
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon1 - lon2);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

module.exports.get_nearest_events = async (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));

    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    const {_id, doc_per_page, page } = body;

    if (!_id) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Person ID is required.'
        });
        return;
    }

    const resultsPerPage = doc_per_page ? parseInt(doc_per_page, 10) : 10;
    const currentPage = page ? parseInt(page, 10) : 1;

    try {
        await connect_to_db();

        const person = await Person.findById(_id);

        if (!person) {
            callback(null, {
                statusCode: 404,
                headers: { 'Content-Type': 'text/plain' },
                body: 'Person not found.'
            });
            return;
        }
        const allEvents = await Event.find();
        const nearestEvents = allEvents.map(event => ({
            id: event._id,
            img_url : event.img_url,
            name : event.name,
            start_date : event.start_date,
            city : event.city,
            price : event.price,
            event_url : event.event_url,
            distance: `${Math.round(haversine(person.coordinateY, person.coordinateX, event.latitude, event.longitude) / 100)} m`
        }));
        nearestEvents.sort((a, b) => {
            const distA = parseInt(a.distance);
            const distB = parseInt(b.distance);
            return distA - distB;
        });
        const paginatedEvents = nearestEvents.slice((currentPage - 1) * resultsPerPage, currentPage * resultsPerPage);

        callback(null, {
            statusCode: 200,
            body: JSON.stringify(paginatedEvents)
        });

    } catch (err) {
        console.error('Error:', err);
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch nearest events.'
        });
    }
};
