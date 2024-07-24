pragma Singleton
import QtQuick

QtObject {
    // Current Temperature Values
    property real tempMax_HLT: 0.0
    property real tempMax_Mash: 0.0
    property real tempMax_Boil: 0.0

    // Setpoint Values
    property real setpointHLTVal: 0.0
    property real setpointMashVal: 0.0
    property real setpointBoilVal: 0.0
    property bool setpointManualHLT: false
    property bool setpointManualMash: false
    property bool setpointManualBoil: false

    // Element Control
    property bool elementHLT_ON: false
    property bool elementBOIL_ON: false

    // Pump Control
    property bool pumpWORT_ON: false
    property bool pumpWATER_ON: false
}
