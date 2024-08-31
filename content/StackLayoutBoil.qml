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

        Column {
            width: parent.width / 2
            height: parent.height

            Item {
                width: parent.width
                height: parent.height / 2
                CustomGraph {
                    id: graph
                    width: parent.width
                    height: parent.height
                    setpointTemp: BreweryValues.setpointTemp_Boil
                    currentTemp: BreweryValues.currentTemp_Boil
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
