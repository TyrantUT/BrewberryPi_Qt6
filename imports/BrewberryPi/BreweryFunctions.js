.pragma library

function getIntToTime(value) {
    var date = new Date(value * 60 * 1000)
    date.setMinutes(date.getMinutes() + date.getTimezoneOffset())
    return date.toLocaleString(Qt.locale(), "hh:mm")
}
