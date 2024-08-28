import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Item {
    property int headerHeight: 50

    Column {
        anchors.fill: parent

        Rectangle {
            height: headerHeight
            width: parent.width
            color: Constants.backgroundColor

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Brewery Status")
                font.bold: true
                font.pixelSize: 24
                color: Constants.textColor
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Constants.backgroundColor
        }

        Rectangle {
            id: top
            width: parent.width - parent.spacing
            height: parent.height - headerHeight - 1
            color: Constants.backgroundColor

            Row {
                width: parent.width / 3
                height: parent.height

                // HLT Dial
                Item {
                    width: parent.width
                    height: parent.height

                    TemperatureGauge {
                        width: Math.min(parent.width, parent.height)
                        height: Math.min(parent.width, parent.height)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        currentTemp: BreweryValues.currentTemp_HLT
                        setpointValue: setManualMode ? BreweryValues.setpointPercent_HLT : BreweryValues.setpointTemp_HLT
                        color: Constants.textColor
                        labelText: qsTr("Hot Liquor Tank")
                        setManualMode: BreweryValues.setpointManual_HLT && !BreweryValues.setpointHltOrMash
                        enabled: !BreweryValues.setpointHltOrMash

                        onValueChangedAndReleased: (setpointValue) => {
                            if (setManualMode) {
                                if (BreweryValues.setpointPercent_HLT !== setpointValue) {
                                    BreweryValues.setpointPercent_HLT = setpointValue;
                                }
                            } else {
                                if (BreweryValues.setpointTemp_HLT !== setpointValue) {
                                    BreweryValues.setpointTemp_HLT = setpointValue;
                                }
                            }
                        }
                    }
                }

                // Mash Dial
                Item {
                    width: parent.width
                    height: parent.height
                    TemperatureGauge {
                        width: Math.min(parent.width, parent.height)
                        height: Math.min(parent.width, parent.height)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        currentTemp: BreweryValues.currentTemp_Mash
                        setpointValue: setManualMode ? BreweryValues.setpointPercent_Mash : BreweryValues.setpointTemp_Mash
                        color: Constants.textColor
                        labelText: qsTr("Mash")
                        setManualMode: BreweryValues.setpointManual_HLT && BreweryValues.setpointHltOrMash
                        enabled: BreweryValues.setpointHltOrMash

                        onValueChangedAndReleased: (setpointValue) => {
                            if (setManualMode) {
                                if (BreweryValues.setpointPercent_Mash !== setpointValue) {
                                    BreweryValues.setpointPercent_Mash = setpointValue;
                                }
                            } else {
                                if (BreweryValues.setpointTemp_Mash !== setpointValue) {
                                    BreweryValues.setpointTemp_Mash = setpointValue;
                                }
                            }
                        }
                    }
                }

                // Boil Dial
                Item {
                    width: parent.width
                    height: parent.height
                    TemperatureGauge {
                        width: Math.min(parent.width, parent.height)
                        height: Math.min(parent.width, parent.height)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        currentTemp: BreweryValues.currentTemp_Boil
                        setpointValue: setManualMode ? BreweryValues.setpointPercent_Boil : BreweryValues.setpointTemp_Boil
                        setManualMode: BreweryValues.setpointManual_Boil
                        color: Constants.textColor
                        labelText: qsTr("Boil")
                        enabled: true

                        onValueChangedAndReleased: (setpointValue) => {
                            if (setManualMode) {
                                if (BreweryValues.setpointPercent_Boil !== setpointValue) {
                                    BreweryValues.setpointPercent_Boil = setpointValue;
                                }
                            } else {
                                if (BreweryValues.setpointTemp_Boil !== setpointValue) {
                                   BreweryValues.setpointTemp_Boil = setpointValue;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
