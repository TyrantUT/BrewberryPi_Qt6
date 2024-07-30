import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Page {
    id: stackLayoutMash

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
            currentTemp: BreweryValues.currentTemp_Mash
            setpointValue: BreweryValues.setpointTemp_Mash
            labelText: qsTr("Mash")
            color: Constants.textColor
            enabled: false
        }
    }
}
