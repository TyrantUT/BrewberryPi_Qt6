pragma Singleton
import QtQuick

QtObject {

    // HLT or Mash mode
    property bool setpointHltOrMash: RPiDataGlobal ? RPiDataGlobal.setpointHltOrMash : false

    onSetpointHltOrMashChanged: RPiDataGlobal.setpointHltOrMash = setpointHltOrMash;

    // Current Temperature Values
    readonly property real currentTemp_HLT: RPiDataGlobal ? RPiDataGlobal.currentTemp_HLT : false
    readonly property real currentTemp_Mash: RPiDataGlobal ? RPiDataGlobal.currentTemp_Mash : false
    readonly property real currentTemp_Boil: RPiDataGlobal ? RPiDataGlobal.currentTemp_Boil : false

    // Setpoint Values
    property real setpointTemp_HLT: RPiDataGlobal ? RPiDataGlobal.setpointTemp_HLT : false
    property real setpointTemp_Mash: RPiDataGlobal ? RPiDataGlobal.setpointTemp_Mash : false
    property real setpointTemp_Boil: RPiDataGlobal ? RPiDataGlobal.setpointTemp_Boil : false
    property int setpointPercent_HLT: RPiDataGlobal ? RPiDataGlobal.setpointPercent_HLT : false
    property int setpointPercent_Mash: RPiDataGlobal ? RPiDataGlobal.setpointPercent_Mash : false
    property int setpointPercent_Boil: RPiDataGlobal ? RPiDataGlobal.setpointPercent_Boil : false

    onSetpointTemp_HLTChanged: RPiDataGlobal.setpointTemp_HLT = setpointTemp_HLT;
    onSetpointTemp_MashChanged: RPiDataGlobal.setpointTemp_Mash = setpointTemp_Mash;
    onSetpointTemp_BoilChanged: RPiDataGlobal.setpointTemp_Boil = setpointTemp_Boil;
    onSetpointPercent_HLTChanged: RPiDataGlobal.setpointPercent_HLT = setpointPercent_HLT;
    onSetpointPercent_MashChanged: RPiDataGlobal.setpointPercent_Mash = setpointPercent_Mash;
    onSetpointPercent_BoilChanged: RPiDataGlobal.setpointPercent_Boil = setpointPercent_Boil;

    property bool setpointManual_HLT: RPiDataGlobal ? RPiDataGlobal.setpointManual_HLT : false
    property bool setpointManual_Boil: RPiDataGlobal ? RPiDataGlobal.setpointManual_Boil : false

    onSetpointManual_HLTChanged: RPiDataGlobal.setpointManual_HLT = setpointManual_HLT;
    onSetpointManual_BoilChanged: RPiDataGlobal.setpointManual_Boil = setpointManual_Boil;

    // Element Control
    property bool elementOn_HLT: RPiDataGlobal ? RPiDataGlobal.elementOn_HLT : false
    property bool elementOn_Boil: RPiDataGlobal ? RPiDataGlobal.elementOn_Boil : false

    onElementOn_HLTChanged: RPiDataGlobal.elementOn_HLT = elementOn_HLT;
    onElementOn_BoilChanged: RPiDataGlobal.elementOn_Boil = elementOn_Boil;

    // Pump Control
    property bool pumpOn_Wort: RPiDataGlobal ? RPiDataGlobal.pumpOn_Wort : false
    property bool pumpOn_Water: RPiDataGlobal ? RPiDataGlobal.pumpOn_Water : false

    onPumpOn_WortChanged: RPiDataGlobal.pumpOn_Wort = pumpOn_Wort;
    onPumpOn_WaterChanged: RPiDataGlobal.pumpOn_Water = pumpOn_Water;

    // Brewery Timer
    property int breweryTimer: 0
}
