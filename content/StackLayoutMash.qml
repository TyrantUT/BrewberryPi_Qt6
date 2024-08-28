import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Item {
    Rectangle {
        anchors.fill: parent
        color: Constants.backgroundColor
    }
    Column {
        width: parent.width / 2
        height: parent.height

        Item {
            width: parent.width
            height: parent.height
            TemperatureGauge {
                id: temperatureGauge
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
}
