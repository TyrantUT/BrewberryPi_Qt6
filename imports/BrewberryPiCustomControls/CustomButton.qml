import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import BrewberryPi

pragma ComponentBehavior: Bound

Button {
    id: control
    property string arrow
    property color backgroundColor: "#FBFBFB"

    contentItem: Text {
        anchors.fill: parent
        text: arrow === "up" ? "\u2191" : (arrow === "down" ? "\u2193" : control.text)
        font.pixelSize: control.height - 4
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Qt.ElideMiddle
        color: Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor
    }

    background: Rectangle {
        anchors.fill: parent
        color: control.down
               ? "#0096FF"
               : control.hovered
               ? (Constants.isDarkTheme ? "#555555" : "#CCCCCC")
               : (Constants.isDarkTheme ? "#444444" : "#E0E0E0")
        border.color: Constants.isDarkTheme ? "#666666" : "#B0B0B0"
        radius: 8

        Rectangle {
            width: parent.width - 4
            height: parent.height - 4
            anchors.centerIn: parent
            color: 'transparent'
            border.color: Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor
            border.width: 4
            opacity: .2
            radius: parent.radius
            visible: control.down
        }
    }
}
