import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Item {
    Rectangle {
        id: mainRectangle
        anchors.fill: parent
        color: Constants.backgroundColor

        TemperatureGauge {
            id: temperatureGauge
            anchors.horizontalCenter: parent.horizontalCenter            
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width / 2
            height: width
            currentTemp: BreweryValues.currentTemp_Boil
            setpointValue: BreweryValues.setpointManual_Boil ? BreweryValues.setpointPercent_Boil : BreweryValues.setpointTemp_Boil
            labelText: qsTr("Boil")
            setManualMode: BreweryValues.setpointManual_Boil
            color: Constants.textColor
            enabled: true

            onValueChangedAndReleased: (setpointValue) => {
                if (BreweryValues.setpointManual_Boil) {
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
