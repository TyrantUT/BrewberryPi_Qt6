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
                width: parent.width
                height: width
                currentTemp: BreweryValues.currentTemp_Mash
                setpointValue: BreweryValues.setpointTemp_Mash
                labelText: qsTr("Mash")
                color: Constants.textColor
                enabled: false
            }
        }
    }
}
