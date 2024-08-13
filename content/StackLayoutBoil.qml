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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 50
                height: width
                currentTemp: BreweryValues.currentTemp_Boil
                setpointValue: setManualMode ? BreweryValues.setpointPercent_Boil : BreweryValues.setpointTemp_Boil
                labelText: qsTr("Boil")
                setManualMode: BreweryValues.setpointManual_Boil
                color: Constants.textColor
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
