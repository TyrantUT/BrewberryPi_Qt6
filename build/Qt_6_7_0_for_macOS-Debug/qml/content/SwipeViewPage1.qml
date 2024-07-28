import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BrewberryPi
import BrewberryPiCustomControls

Page {
    Column {
        spacing: 2
        width: parent.width / 2
        height: parent.height

        TemperatureGauge {
            id: gauge_HLT
            width: parent.width
            height: parent.height / 3
            currentTemperature: 220
        }
        TemperatureGauge {
            id: gauge_Mash
            width: parent.width
            height: parent.height / 3
            currentTemperature: BreweryValues.currentTemp_Mash
        }
        TemperatureGauge {
            id: gauge_Boil
            width: parent.width
            height: parent.height / 3
            currentTemperature: 220
        }

    }
}
