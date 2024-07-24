pragma Singleton
import QtQuick

QtObject {
    readonly property int width: 1024
    readonly property int height: 600

    property string relativeFontDirectory: "fonts"

    /* Edit this comment to add your custom font */
    readonly property font font: Qt.font({
                                             family: Qt.application.font.family,
                                             pixelSize: Qt.application.font.pixelSize
                                         })
    readonly property font largeFont: Qt.font({
                                                  family: Qt.application.font.family,
                                                  pixelSize: Qt.application.font.pixelSize * 1.6
                                              })

    readonly property color backgroundColor: AppSettings.isDarkTheme ? "#FFFFFF" : "#000000"
    readonly property color accentColor: AppSettings.isDarkTheme ? "#002125" : "#FFFFFF"
    readonly property color primaryTextColor: AppSettings.isDarkTheme ? "#FFFFFF" : "#000000"
    readonly property color accentTextColor: AppSettings.isDarkTheme ? "#D9D9D9" : "#898989"
    readonly property color iconColor: AppSettings.isDarkTheme ? "#D9D9D9" : "#00414A"


    // Radial Bar
    readonly property int labelSize: 12
    readonly property int degSize: 24
    readonly property real minVal: 0.0
    readonly property real maxVal: 215.0
    readonly property string tempBarSuffix: "°"
    readonly property real dialWidth: 10
    readonly property color tempColor: "#00ffc1"
    readonly property color progressColor: "#00ffc1"
    readonly property color foregroundColor: "#ffffff"
    readonly property color setPointTextColor: "#000000"
    readonly property color setPointBarColor: "#adadad"
    readonly property color radialBarLabelColor: "#000000"

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
