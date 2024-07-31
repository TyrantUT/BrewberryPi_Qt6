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

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            id: timeDisplay
            text: Qt.formatTime(new Date(remainingTime * 1000), "mm:ss")
            font.pixelSize: 32
        }

        Button {
            id: startButton
            text: "Start"
            onClicked: {
                timer.start()
                startButton.enabled = false
                stopButton.enabled = true
                resetButton.enabled = false
            }
        }

        Button {
            id: stopButton
            text: "Stop"
            enabled: false
            onClicked: {
                timer.stop()
                startButton.enabled = true
                stopButton.enabled = false
                resetButton.enabled = true
            }
        }

        Button {
            id: resetButton
            text: "Reset"
            onClicked: {
                timer.stop()
                remainingTime = countdownTime
                startButton.enabled = true
                stopButton.enabled = false
            }
        }

        Row {
            spacing: 10

            Text {
                text: "Set Time (seconds):"
            }

            SpinBox {
                id: timeSetter
                from: 1
                to: 3600
                value: countdownTime
                onValueChanged: {
                    countdownTime = timeSetter.value
                    remainingTime = countdownTime
                }
            }
        }
    }
}
