import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Page {
    id: stackLayoutBoil

    Rectangle {
        id: mainRectangle
        anchors.fill: parent
        color: Constants.backgroundColor

        TemperatureBar {
            id: temperatureBar
            anchors.horizontalCenter: parent.horizontalCenter            
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width / 2
            height: width
            from: 0
            to: 220
            stepSize: 1
            startAngle: -140
            endAngle: 140
            currentTemp: BreweryValues.currentTemp_Boil

            onValueChangedAndReleased: (setpointValue) => {
                if (BreweryValues.setpoint_Boil !== setpointValue) {
                    BreweryValues.setpoint_Boil = setpointValue;
                }
            }
        }
    }
}
