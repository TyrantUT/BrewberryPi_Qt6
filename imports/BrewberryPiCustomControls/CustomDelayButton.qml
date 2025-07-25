import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import BrewberryPi

pragma ComponentBehavior: Bound

DelayButton {
    id: control
    delay: 1000
    font.bold: true
    font.pointSize: 22
    text: qsTr("Off")

    onProgressChanged: canvas.requestPaint()

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
    }

    // Drop shadow under entire button
    Rectangle {
        width: control.width
        height: control.height
        anchors.centerIn: parent
        radius: width / 2
        color: Qt.rgba(0, 0, 0, 0.5)
        opacity: 0.3
        z: -2
    }

    background: Item {
        id: background
        width: control.width
        height: control.width
        anchors.centerIn: parent

        // Outer shell with theme-aware gradient
        Rectangle {
            id: shell
            width: parent.width
            height: parent.height
            radius: width / 2
            color: Qt.darker(Constants.backgroundColor, 1.8)
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.lighter(Constants.darkColor, 1.2) }
                GradientStop { position: 1.0; color: Qt.darker(Constants.darkColor, 2.0) }
            }
            z: 0
        }

        // Inner button
        Item {
            id: pressableInner
            width: parent.width * 0.9
            height: width
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

            // Inner button face
            Rectangle {
                id: inner
                anchors.fill: parent
                radius: width / 2
                property color baseColor: control.down
                    ? Constants.warningColor
                    : (control.checked ? Constants.dangerColor : Constants.successColor)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.lighter(inner.baseColor, 1.8) }
                    GradientStop { position: 0.4; color: inner.baseColor }
                    GradientStop { position: 1.0; color: Qt.darker(inner.baseColor, 1.4) }
                }
            }

            // Inner bevel
            Rectangle {
                width: parent.width - 16
                height: parent.height - 16
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

            // Gradient glow blended with button color
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

        // Progress ring with shadow
        Item {
            id: canvasContainer
            anchors.fill: parent
            anchors.margins: 6
            z: 6

            Canvas {
                id: canvas
                anchors.fill: parent
                visible: control.pressed
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    // Color based on progress
                    const r = Constants.successColor.r + (Constants.dangerColor.r - Constants.successColor.r) * control.progress;
                    const g = Constants.successColor.g + (Constants.dangerColor.g - Constants.successColor.g) * control.progress;
                    const b = Constants.successColor.b + (Constants.dangerColor.b - Constants.successColor.b) * control.progress;
                    ctx.strokeStyle = Qt.rgba(r, g, b, 0.85);
                    ctx.lineWidth = parent.width / 24;
                    const start = Math.PI * 0.6;
                    const end = start + control.progress * Math.PI * 1.8;
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2, width / 2 - ctx.lineWidth / 2 - 2, start, end);
                    ctx.stroke();
                }
            }

            MultiEffect {
                anchors.fill: canvas
                source: canvas
                shadowEnabled: control.checked
                shadowOpacity: 0.3
                shadowBlur: 0.1
                shadowColor: Qt.rgba(0, 0, 0, 0.5)
                shadowVerticalOffset: 1
                shadowHorizontalOffset: 1
                visible: control.pressed
            }
        }
    }

    onCheckedChanged: text = checked ? qsTr("On") : qsTr("Off")
}
