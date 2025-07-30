import QtQuick
import QtQuick.Controls.Basic
import BrewberryPi

pragma ComponentBehavior: Bound

Switch {
    id: control
    font.bold: true
    text: qsTr("Off")

    property int outerBevelPixelSize: 16

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: Constants.lightColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        anchors.centerIn: parent
        z: 10

        transform: Scale {
            origin.x: pressableInner.width / 2
            origin.y: pressableInner.height / 2
            xScale: control.down ? 0.88 : 1.0
            yScale: control.down ? 0.88 : 1.0
            Behavior on xScale { NumberAnimation { duration: 80 } }
            Behavior on yScale { NumberAnimation { duration: 80 } }
        }
    }

    // Drop shadow under entire switch
    Rectangle {
        width: control.width
        height: control.height
        anchors.centerIn: parent
        radius: width / 2
        color: Qt.rgba(0, 0, 0, 0.5)
        opacity: 0.3
        z: -2
    }

    indicator: Item {
        id: background
        width: control.width
        height: control.height
        anchors.centerIn: parent

        // Outer shell with theme-aware gradient
        Rectangle {
            id: shell
            width: parent.width
            height: parent.height
            radius: height / 2
            color: Qt.darker(Constants.backgroundColor, 1.8)
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.lighter(Constants.darkColor, 1.2) }
                GradientStop { position: 1.0; color: Qt.darker(Constants.darkColor, 2.0) }
            }
            z: 0
        }

        // Inner switch
        Item {
            id: pressableInner
            width: parent.width * 0.88
            height: parent.height * 0.88
            anchors.centerIn: parent
            z: 2

            transform: Scale {
                origin.x: pressableInner.width / 2
                origin.y: pressableInner.height / 2
                xScale: control.down ? 0.88 : 1.0
                yScale: control.down ? 0.88 : 1.0
                Behavior on xScale { NumberAnimation { duration: 80 } }
                Behavior on yScale { NumberAnimation { duration: 80 } }
            }

            // Inner switch face
            Rectangle {
                id: inner
                anchors.fill: parent
                radius: height / 2
                property color baseColor: control.down
                    ? Constants.warningColor
                    : (control.checked ? Constants.dangerColor : Constants.successColor)

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.lighter(inner.baseColor, 1.8) }
                    GradientStop { position: 0.4; color: inner.baseColor }
                    GradientStop { position: 1.0; color: Qt.darker(inner.baseColor, 1.4) }
                }
            }

            // Inner bevel, further from edge
            Rectangle {
                width: parent.width - control.outerBevelPixelSize
                height: parent.height - control.outerBevelPixelSize
                radius: height / 2
                anchors.centerIn: parent
                color: 'transparent'
                border.color: Qt.darker(inner.baseColor, 1.8)
                border.width: 3
                z: 3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.4) }
                    GradientStop { position: 0.8; color: 'transparent' }
                }
            }

            // Gradient glow blended with switch color
            Rectangle {
                width: parent.width - 20
                height: parent.height - 20
                radius: height / 2
                anchors.centerIn: parent
                color: 'transparent'
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.7) }
                    GradientStop { position: 1.0; color: Qt.lighter(inner.baseColor, 1.2) }
                }
                border.width: 2
                border.color: Qt.rgba(1, 1, 1, 0.5)
                opacity: control.down ? 0.4 : 0.8
                z: 4
            }

            // Subtle press overlay
            Rectangle {
                visible: control.down
                anchors.fill: inner
                radius: inner.radius
                color: Qt.rgba(0, 0, 0, 0.15)
                z: 5
            }
        }
    }
}
