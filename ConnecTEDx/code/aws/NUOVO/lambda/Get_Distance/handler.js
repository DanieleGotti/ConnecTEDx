const connect_to_db = require('./db');
const Person = require('./Person');

require('dotenv').config({ path: './variables.env' });

function haversine(lat1, lon1, lat2, lon2) {
    function toRad(x) {
        return x * Math.PI / 180;
    }

    const R = 6371000; 
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon1 - lon2);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

module.exports.get_nearest_people = async (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));

    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    const { id, doc_per_page, page } = body;

    if (!id) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'ID is required.'
        });
        return;
    }

    const resultsPerPage = doc_per_page ? parseInt(doc_per_page, 10) : 10;
    const currentPage = page ? parseInt(page, 10) : 1;

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

        const allPeople = await Person.find({ _id: { $ne: id } });

        const nearestPeople = allPeople.map(p => ({
            id: p._id,
            distance: `${Math.round(haversine(person.coordinateY, person.coordinateX, p.coordinateY, p.coordinateX) / 1000)} Km` // Convert to kilometers and round to nearest integer, then format as "x Km"
        }));

        nearestPeople.sort((a, b) => {
            const distA = parseInt(a.distance);
            const distB = parseInt(b.distance);
            return distA - distB;
        });

        const paginatedPeople = nearestPeople.slice((currentPage - 1) * resultsPerPage, currentPage * resultsPerPage);

        callback(null, {
            statusCode: 200,
            body: JSON.stringify(paginatedPeople)
        });

    } catch (err) {
        console.error('Error:', err);
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch nearest people.'
        });
    }
};