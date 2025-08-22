import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Item {
    id: control

    Rectangle {
        height: parent.height
        width: parent.width
        color: Constants.isDarkTheme ? Constants.lightDarkColor : Constants.lightColor
    }

    Row {
        width: parent.width / 3
        height: parent.height

        // HLT Column
        Column {
            width: parent.width
            height: parent.height

            Row {
                width: parent.width / 2
                height: parent.height

                Column {
                    width: parent.width
                    height: parent.height / 2

                    Item {
                        width: parent.width
                        height: parent.height / 3

                        Text {
                            text: 'PID Mode'
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Constants.textColor
                            font.pixelSize: height
                            font.bold: true
                        }
                    }

                    Item {
                        width: parent.width - 4
                        height: width

                        CustomToggleSwitch {
                            width: parent.width / 2
                            height: width
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: checked ? "Manual" : "Auto"
                            font.pixelSize: height / 6
                            checked: BreweryValues.setpointManual_HLT
                            onCheckedChanged: BreweryValues.setpointManual_HLT = checked
                        }
                    }
                }

                Column {
                    width: parent.width
                    height: parent.height

                    Item {
                        width: parent.width
                        height: parent.height

                        Text {
                            text: 'HLT Element'
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Constants.textColor
                            font.pixelSize: height
                            font.bold: true
                        }

                        CustomDelayButton {
                            width: parent.width * .75
                            height: width
                            anchors.centerIn: parent
                            checked: BreweryValues.elementOn_HLT
                            enabled: !BreweryValues.elementOn_Boil
                            font.pixelSize: height / 6
                            onCheckedChanged: BreweryValues.elementOn_HLT = checked
                        }
                    }
                }
            }
        }

        // Center Column
        Column {
            width: parent.width
            height: parent.height

            Row {
                width: parent.width / 2
                height: parent.height / 2

                Column {
                    width: parent.width
                    height: parent.height / 2

                    Item {
                        width: parent.width
                        height: parent.height - 10

                        Text {
                            text: 'Pump 1'
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Constants.textColor
                            font.pixelSize: height
                            font.bold: true
                        }
                    }

                    Item {
                        width: parent.width
                        height: parent.height

                        CustomToggleSwitch {
                            width: parent.width / 2 - 25
                            height: width
                            anchors.centerIn: parent
                            text: checked ? "On" : "Off"
                            font.pixelSize: height / 6
                            checked: BreweryValues.pumpOn_Water
                            onCheckedChanged: BreweryValues.pumpOn_Water = checked
                        }
                    }
                }

                Column {
                    width: parent.width
                    height: parent.height / 2

                    Item {
                        width: parent.width
                        height: parent.height - 10

                        Text {
                            text: 'Pump 2'
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Constants.textColor
                            font.pixelSize: height
                            font.bold: true
                        }
                    }

                    Item {
                        width: parent.width
                        height: parent.height

                        CustomToggleSwitch {
                            width: parent.width / 2 - 25
                            height: width
                            anchors.centerIn: parent
                            text: checked ? "On" : "Off"
                            font.pixelSize: height / 6
                            checked: BreweryValues.pumpOn_Wort
                            onCheckedChanged: BreweryValues.pumpOn_Wort = checked
                        }
                    }
                }
            }

            Row {
                width: parent.width
                height: parent.height / 2

                Item {
                    width: parent.width
                    height: parent.height

                    CountdownTimer {
                        width: parent.width
                        height: parent.height
                        anchors.centerIn: parent
                        remainingTime: BreweryValues.breweryTimer

                        onRemainingTimeChanged: () => {
                            BreweryValues.breweryTimer = remainingTime;
                        }
                    }
                }
            }
        }

        // Boil Column
        Column {
            width: parent.width
            height: parent.height

            Row {
                width: parent.width / 2
                height: parent.height

                Column {
                    width: parent.width
                    height: parent.height

                    Item {
                        width: parent.width
                        height: parent.height

                        Text {
                            text: 'Boil Element'
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Constants.textColor
                            font.pixelSize: height
                            font.bold: true
                        }

                        CustomDelayButton {
                            width: parent.width * .75
                            height: width
                            anchors.centerIn: parent
                            checked: BreweryValues.elementOn_Boil
                            enabled: !BreweryValues.elementOn_HLT
                            font.pixelSize: height / 6
                            onCheckedChanged: BreweryValues.elementOn_Boil = checked
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: parent.height

                    Column {
                        width: parent.width
                        height: parent.height / 2

                        Item {
                            width: parent.width
                            height: parent.height / 3

                            Text {
                                text: 'PID Mode'
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Constants.textColor
                                font.pixelSize: height
                                font.bold: true
                            }
                        }

                        Item {
                            width: parent.width - 4
                            height: width

                            CustomToggleSwitch {
                                width: parent.width / 2
                                height: width
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: checked ? "Manual" : "Auto"
                                font.pixelSize: height / 6
                                checked: BreweryValues.setpointManual_Boil
                                onCheckedChanged: BreweryValues.setpointManual_Boil = checked
                            }
                        }
                    }
                }
            }
        }
    }
}
