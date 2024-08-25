pragma Singleton
import QtQuick

QtObject {

    Connections {
        target: RPiDataGlobal

        function onAboutToBeDestroyed() {
            RPiDataGlobal = null;
        }
    }

    // HLT or Mash mode
    property bool setpointHltOrMash: RPiDataGlobal.setpointHltOrMash

    // Current Temperature Values
    property real currentTemp_HLT: RPiDataGlobal.currentTemp_HLT
    property real currentTemp_Mash: RPiDataGlobal.currentTemp_Mash
    property real currentTemp_Boil: RPiDataGlobal.currentTemp_Boil

    // Setpoint Values
    property real setpointTemp_HLT: RPiDataGlobal.setpointTemp_HLT
    property real setpointTemp_Mash: RPiDataGlobal.setpointTemp_Mash
    property real setpointTemp_Boil: RPiDataGlobal.setpointTemp_Boil
    property int setpointPercent_HLT: RPiDataGlobal.setpointPercent_HLT
    property int setpointPercent_Mash: RPiDataGlobal.setpointPercent_Mash
    property int setpointPercent_Boil: RPiDataGlobal.setpointPercent_Boil

    property bool setpointManual_HLT: RPiDataGlobal.setpointManual_HLT
    property bool setpointManual_Mash: RPiDataGlobal.setpointManual_Mash
    property bool setpointManual_Boil: RPiDataGlobal.setpointManual_Boil

    // Element Control
    property bool elementOn_HLT: RPiDataGlobal.elementOn_HLT
    property bool elementOn_Boil: RPiDataGlobal.elementOn_Boil

    // Pump Control
    property bool pumpOn_Wort: RPiDataGlobal.pumpOn_Wort
    property bool pumpOn_Water: RPiDataGlobal.pumpOn_Water

    // Brewery Timer
    property int breweryTimer: 0
}
