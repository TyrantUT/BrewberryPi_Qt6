import QtQuick
import QtQuick.Controls
import BrewberryPi

pragma ComponentBehavior: Bound

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
                    text: Qt.formatTime(new Date(remainingTime * 1000), "mm:ss")
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
                            text: qsTr("Mash")
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
                            text: qsTr("Boil")
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
                    text: qsTr("Start")
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
                }
            }
        }
    }
}
