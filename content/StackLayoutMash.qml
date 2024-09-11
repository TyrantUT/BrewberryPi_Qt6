import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Item {
    Rectangle {
        anchors.fill: parent
        color: Constants.backgroundColor
    }

    Row {
        width: parent.width
        height: parent.height
        Column {
            width: parent.width / 2
            height: parent.height

            Item {
                width: parent.width
                height: parent.height

                TemperatureGauge {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 50
                    height: width
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
        }

        Column {
            width: parent.width / 2
            height: parent.height

            Item {
                width: parent.width
                height: parent.height / 2
                CustomGraph {
                    id: graph
                    setpointTemp: BreweryValues.setpointTemp_Mash
                    currentTemp: BreweryValues.currentTemp_Mash
                }
            }

            Item {
                width: parent.width
                height: parent.height / 2
                Item {
                    width: parent.width
                    height: parent.height / 4
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    CustomTimerBox {
                        width: parent.width
                        height: parent.height
                    }
                }

            }
        }
    }
}
