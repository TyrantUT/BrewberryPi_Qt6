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
        }

        Column {
            width: parent.width / 2
            height: parent.height

            Item {
                width: parent.width
                height: parent.height / 2
                CustomGraph {
                    id: graph
                    chartLabel: "Hot Liquor Tank"
                    currentTemp: BreweryValues.currentTemp_HLT
                    setpointTemp: BreweryValues.setpointTemp_HLT
                    width: parent.width
                    height: parent.height
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
