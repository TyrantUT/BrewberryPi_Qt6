pragma Singleton
import QtQuick

QtObject {
    // Current Temperature Values
    property real currentTemp_HLT: 0.0
    property real currentTemp_Mash: 0.0
    property real currentTemp_Boil: 0.0

    // Setpoint Values
    property real setpoint_HLT: 0.0
    property real setpoint_Mash: 0.0
    property real setpoint_Boil: 0.0
    property bool setpintManual_HLT: false
    property bool setpintManual_Mash: false
    property bool setpintManual_Boil: false

    // Element Control
    property bool elementOn_HLT: false
    property bool elementOn_Boil: false

    // Pump Control
    property bool pumpOn_Wort: false
    property bool pumpOn_Water: false
}
