import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material.impl
import BrewberryPi

pragma ComponentBehavior: Bound

T.Switch {
    id: control
    anchors.horizontalCenter: control.horizontalCenter

    Text {
        text: parent.text
        anchors {
            verticalCenter: control.verticalCenter
            horizontalCenter: control.horizontalCenter
        }
        z: 1
        font.bold: true
        color: Constants.lightColor
    }

    // Outside Shadow
    Rectangle {
        width: parent.width + 2
        height: parent.height + 2
        radius: height / 2
        color: Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor
        opacity: 0.1
        anchors.centerIn: parent
    }

    indicator: Rectangle {

        // Shadow effect using multiple rectangles
        Rectangle {
            property color darkBorder: (Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor)
            property color lightBorder: (Constants.isDarkTheme ? Constants.darkColor : Constants.lightColor)
            width: parent.width - 2
            height: parent.height - 2
            radius: height / 2
            opacity: 0.4
            anchors.centerIn: parent
            color: 'transparent'
            border.color: control.checked ? darkBorder : lightBorder
            border.width: 2
        }

        anchors.horizontalCenter: control.horizontalCenter
        width: parent.width - 2
        height: parent.height - 2
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: width / 2
        color: control.down ? Constants.warningColor : (control.checked ? Constants.dangerColor : Constants.successColor)
    }
}
