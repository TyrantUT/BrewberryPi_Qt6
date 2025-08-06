import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import BrewberryPi

pragma ComponentBehavior: Bound

Button {
    id: root

    // Properties for customization
    property color backgroundColor: "#888888"
    property color textColor: "white"
    property color borderColor: Constants.isDarkTheme ? Constants.backgroundColor : Qt.darker(Constants.backgroundColor, 1.6)

    font.pixelSize: 18

    Rectangle {
        id: outerShadow
        width: parent.width + 4
        height: parent.height + 4
        radius: height / 2
        color: Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor
        opacity: root.down ? 0.05 : 0.1
        anchors.centerIn: parent
    }

    background: Rectangle {
        id: backgroundRect
        color: root.down ? Qt.darker(root.backgroundColor, 1.2) : root.backgroundColor
        border.color: root.down ? Qt.darker(root.borderColor, 1.2) : root.borderColor
        border.width: root.down ? 2 : 1
        radius: 12

        Rectangle {
            id: innerShadow
            width: parent.width - 4
            height: parent.height - 4
            anchors.centerIn: parent
            color: 'transparent'
            border.color: Constants.darkColor
            border.width: root.down ? 2 : 0
            opacity: root.down ? 0.3 : 0
            radius: parent.radius
        }

        MultiEffect {
            anchors.fill: backgroundRect
            source: backgroundRect
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, root.down ? 0.4 : 0.2)
            shadowBlur: root.down ? 2 : 3
            shadowHorizontalOffset: 0
            shadowVerticalOffset: root.down ? 1 : 2
            shadowOpacity: root.down ? 0.6 : 0.3
            autoPaddingEnabled: true
        }
    }

    contentItem: Text {
        id: buttonText
        text: root.text
        font: root.font
        anchors.centerIn: parent
        color: root.textColor
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    onClicked: {
        buttonAnimation.start()
    }

    SequentialAnimation {
        id: buttonAnimation
        PropertyAnimation {
            target: root
            property: "scale"
            to: 0.95
            duration: 50
        }
        PropertyAnimation {
            target: buttonText
            property: "scale"
            to: 0.9
            duration: 50
        }
        PropertyAnimation {
            target: root
            property: "scale"
            to: 1.0
            duration: 50
        }
        PropertyAnimation {
            target: buttonText
            property: "scale"
            to: 1.0
            duration: 50
        }
    }
}
