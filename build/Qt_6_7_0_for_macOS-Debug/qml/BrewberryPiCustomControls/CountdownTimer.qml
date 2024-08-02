import QtQuick
import QtQuick.Controls
import BrewberryPi

pragma ComponentBehavior: Bound

Item {

    property int countdownTime: 0

    Timer {
        id: timer
        interval: 1000 // 1 second
        repeat: true
        running: false
        onTriggered: {
            countdownTime--;
            if (countdownTime == 0) {
                timer.stop()
            }
        }
    }

    Row {
        width: parent.width
        height: parent.height
        spacing: 2

        Column {
            width: parent.width * .75
            height: parent.height / 2

            Item {
                width: parent.width
                height: parent.height
                Text {
                    height: parent.height
                    width: parent.width
                    text: {
                        var date = new Date(countdownTime * 60 * 1000)
                        date.setMinutes(date.getMinutes() + date.getTimezoneOffset())
                        return date.toLocaleString(Qt.locale(), "hh:mm")
                    }

                    color: Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor
                    font.pixelSize: parent.height
                    elide: Qt.ElideMiddle
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    Rectangle {
                        width: parent.width - 4
                        height: 2
                        color: 'lightblue'
                        anchors.bottom: parent.bottom
                    }
                }
            }
            Item {
                width: parent.width
                height: parent.height

                Row {
                    width: parent.width / 2
                    height: parent.height

                    Item {
                        width: parent.width
                        height: parent.height

                        CustomButton {
                            width: parent.width / 2
                            height: parent.height / 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("60")

                            onClicked: countdownTime = 60

                        }
                    }

                    Item {
                        width: parent.width
                        height: parent.height

                        CustomButton {
                            width: parent.width / 2
                            height: parent.height / 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("90")

                            onClicked: countdownTime = 90
                        }
                    }
                }
            }
        }

        Column {
            width: parent.width * .25
            height: parent.height

            // Up button
            Item {
                width: parent.width
                height: parent.height / 3
                CustomButton {
                    width: parent.width / 2
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    arrow: "up"

                    onClicked: countdownTime += 1
                }
            }

            // Start Button
            Item {
                width: parent.width
                height: parent.height / 3
                CustomButton {
                    width: parent.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: timer.running ? qsTr("Stop") : qsTr("Start")

                    onClicked: timer.running ? timer.stop() : timer.start()
                }
            }

            // Up button
            Item {
                width: parent.width
                height: parent.height / 3
                CustomButton {
                    width: parent.width / 2
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    arrow: "down"

                    onClicked: countdownTime -= 1
                }
            }
        }
    }
}
