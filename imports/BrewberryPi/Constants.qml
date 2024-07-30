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
    property bool isDarkTheme: true
    readonly property color primaryColor: "#3B71CA"
    readonly property color secondaryColor: "#9FA6B2"
    readonly property color successColor: "#14A44D"
    readonly property color dangerColor: "#DC4C64"
    readonly property color warningColor: "#E4A11B"
    readonly property color infoColor: "#54B4D3"
    readonly property color lightColor: "#FBFBFB"
    readonly property color darkColor: "#332D2D"

    readonly property color backgroundColor: isDarkTheme ? darkColor : lightColor
    readonly property color textColor: isDarkTheme ? secondaryColor : primaryColor

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

}
