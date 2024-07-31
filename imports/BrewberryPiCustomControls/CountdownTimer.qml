import QtQuick
import QtQuick.Controls
import BrewberryPi

Item {

    property int countdownTime: 60 // Set the countdown time in seconds
    property int remainingTime: countdownTime

    Timer {
        id: timer
        interval: 1000 // 1 second interval
        repeat: true
        running: false
        onTriggered: {
            if (remainingTime > 0) {
                remainingTime -= 1
            } else {
                timer.stop()
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 2


    }

}
