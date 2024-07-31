pragma Singleton
import QtQuick

QtObject {
    // Current Temperature Values
    property real currentTemp_HLT: 0.0
    property real currentTemp_Mash: 0.0
    property real currentTemp_Boil: 0.0

    // Setpoint Values
    property real setpointTemp_HLT: 0.0
    property real setpointTemp_Mash: 0.0
    property real setpointTemp_Boil: 0.0
    property int setpointPercent_HLT: 0
    property int setpointPercent_Mash: 0
    property int setpointPercent_Boil: 0

    property bool setpointManual_HLT: false
    property bool setpointManual_Mash: false
    property bool setpointManual_Boil: false

    // Element Control
    property bool elementOn_HLT: false
    property bool elementOn_Boil: false

    // Pump Control
    property bool pumpOn_Wort: false
    property bool pumpOn_Water: false

    // Brewery Value
    property int breweryTimer: 0
}
