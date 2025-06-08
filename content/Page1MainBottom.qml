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
        spacing: 2
        width: parent.width / 3
        height: parent.height

        // HLT Column
        Column {
            width: parent.width
            height: parent.height

            Row {
                width: parent.width / 2
                height: parent.height

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
                            width: parent.width
                            height: parent.height / 2

                            CustomToggleSwitch {
                                width: parent.width
                                height: parent.height
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: checked ? "Manual" : "Automatic"
                                font.pixelSize: height
                                checked: BreweryValues.setpointManual_HLT
                                onCheckedChanged: BreweryValues.setpointManual_HLT = checked
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: parent.height

                    Column {
                        width: parent.width
                        height: parent.height

                        Text {
                            text: 'HLT Element'
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Constants.textColor
                            font.pixelSize: height
                            font.bold: true
                        }

                        Item {
                            width: parent.width
                            height: parent.height

                            CustomDelayButton {
                                width: parent.width * .75
                                height: parent.height * .75
                                anchors.centerIn: parent
                                checked: BreweryValues.elementOn_HLT
                                enabled: !BreweryValues.elementOn_Boil
                                onCheckedChanged: BreweryValues.elementOn_HLT = checked
                            }
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
                width: parent.width / 3
                height: parent.height / 2.2


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
                            width: parent.width / 2
                            height: parent.height / 2 + 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: checked ? "On" : "Off"
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
                            text: 'Mode'
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
                            width: parent.width / 2
                            height: parent.height / 2 + 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: checked ? "Mash" : "HLT"
                            checked: BreweryValues.setpointHltOrMash
                            onCheckedChanged: BreweryValues.setpointHltOrMash = checked
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
                            width: parent.width / 2
                            height: parent.height / 2 + 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: checked ? "On" : "Off"
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
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        countdownTime: BreweryValues.breweryTimer

                        onCountdownTimeChanged: (cuontdownTime) => {
                            BreweryValues.breweryTimer = countdownTime;
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

                Item {
                    width: parent.width
                    height: parent.height

                    Column {
                        width: parent.width
                        height: parent.height

                        Text {
                            text: 'Boil Element'
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Constants.textColor
                            font.pixelSize: height
                            font.bold: true
                        }

                        Item {
                            width: parent.width
                            height: parent.height

                            CustomDelayButton {
                                width: parent.width * .75
                                height: parent.height * .75
                                anchors.centerIn: parent
                                checked: BreweryValues.elementOn_Boil
                                enabled: !BreweryValues.elementOn_HLT
                                onCheckedChanged: BreweryValues.elementOn_Boil = checked
                            }
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
                            width: parent.width
                            height: parent.height / 2

                            CustomToggleSwitch {
                                width: parent.width
                                height: parent.height
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: checked ? "Manual" : "Automatic"
                                font.pixelSize: height
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
