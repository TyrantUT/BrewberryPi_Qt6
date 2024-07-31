import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Page {
    id: stackLayoutHLT

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
            currentTemp: BreweryValues.currentTemp_HLT
            setpointValue: setManualMode ? BreweryValues.setpointPercent_HLT : BreweryValues.setpointTemp_HLT
            labelText: qsTr("Hot Liquor Tank")
            setManualMode: BreweryValues.setpointManual_HLT
            color: Constants.textColor
            enabled: true

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
