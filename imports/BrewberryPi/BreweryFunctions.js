.pragma library

function getIntToTime(value) {
    var date = new Date(null);
    date.setSeconds(value);
    return date.toISOString().substr(11, 8);
}
