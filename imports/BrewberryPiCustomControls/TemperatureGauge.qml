import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects
import BrewberryPi

pragma ComponentBehavior: Bound

Dial {
    id: control
    property color color: '#000000'
    property alias dialColor: control.color
    property real currentTemp: 0.0
    property string labelText: ''
    property bool setManualMode: false
    property alias setpointValue: control.value
    property int capStyle: Qt.RoundCap
    property color trackColor: "#505050"
    property color progressColor: "#3a4ec4"
    property color handleColor: "#fefefe"
    property real currentAngle: startAngle + (endAngle - startAngle) * (currentTemp - from) / (to - from)
    property color gradientColor: Qt.rgba((currentAngle - startAngle) / (endAngle - startAngle), 0, 1 - (currentAngle - startAngle) / (endAngle - startAngle), 1)
    property real currentAngleSetPoint: startAngle + (endAngle - startAngle) * (value - from) / (to - from)
    property color currentColorSetPoint: Qt.rgba((currentAngleSetPoint - startAngle) / (endAngle - startAngle), 0, 1 - (currentAngleSetPoint - startAngle) / (endAngle - startAngle), 1)
    property int outerHandleSize: Math.max(control.handle.width, control.handle.height)
    readonly property string suffixText: setManualMode ? "%" : "°"

    signal valueChangedAndReleased(real setpointValue)

    visible: true
    antialiasing: true
    from: 0
    to: setManualMode ? 100 : 220
    stepSize: 1
    startAngle: -140
    endAngle: 140
    inputMode: Dial.Circular
    wrap: false

    // Drop shadow under entire dial


    // Outer ring with theme-aware gradient


    background: Item {
        width: control.width - 2
        height: control.height - 2
        anchors.centerIn: parent

        Rectangle {
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
            radius: width / 2
            color: Qt.rgba(0, 0, 0, 0.5)
            opacity: 0.25
            z: -3
        }

        Rectangle {
            id: shell
            width: parent.width
            height: parent.height
            radius: width / 2
            anchors.centerIn: parent
            color: Constants.backgroundColor
            border.color: Qt.darker(Constants.backgroundColor, 1.8)
            border.width: 2
        }
    }

    Connections {
        target: Constants
        function onIsDarkThemeChanged() {
            canvas.requestPaint()
        }
    }

    onSetManualModeChanged: {
        canvas.requestPaint()
    }

    onPressedChanged: {
        if (!pressed) {
            valueChangedAndReleased(setpointValue)
        }
    }

    handle: Item {
        id: handleItem
        width: 20
        height: width * 2
        anchors.centerIn: parent
        visible: enabled

        Shape {
            id: handleShape
            width: parent.width
            height: parent.height

            ShapePath {
                startX: 10
                startY: 0
                PathLine { x: 20; y: 20 }
                PathLine { x: 0; y: 20 }
                PathLine { x: 10; y: 0 }
                PathLine { x: 10; y: 0 }
                fillColor: currentColorSetPoint
                strokeColor: 'transparent'
            }
        }

        MultiEffect {
            anchors.fill: handleShape
            source: handleShape
            shadowEnabled: true
            shadowOpacity: 0.4
            shadowBlur: 0.1
            shadowColor: Qt.rgba(0, 0, 0, 0.5)
        }

        state: "unpressed"
        states: [
            State {
                name: "pressed"
                PropertyChanges { target: handleShape; opacity: Constants.isDarkTheme ? 0.9 : 0.7 }
            },
            State {
                name: "unpressed"
                PropertyChanges { target: handleShape; opacity: Constants.isDarkTheme ? 0.6 : 0.3 }
            }
        ]

        transitions: [
            Transition {
                from: "unpressed"
                to: "pressed"
                NumberAnimation { target: handleShape; property: "opacity"; duration: 100; easing.type: Easing.InOutQuad }
            },
            Transition {
                from: "pressed"
                to: "unpressed"
                NumberAnimation { target: handleShape; property: "opacity"; duration: 100; easing.type: Easing.InOutQuad }
            }
        ]

        transform: [
            Translate { y: -Math.min(control.width, control.height) * 0.33 + handleItem.height / 2 },
            Rotation { angle: control.angle; origin.x: handleItem.width / 2; origin.y: handleItem.height / 2 }
        ]
    }

    Item {
        id: canvasContainer
        anchors.centerIn: parent
        width: control.width - 10
        height: width
        z: 2

        Canvas {
            id: canvas
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var centerX = width / 2
                var centerY = height / 2
                var radius = width / 2 - (outerShapePath.strokeWidth * 2)
                var largeTickLength = 15
                var smallTickLength = 7
                var labelRadius = radius - largeTickLength - 20
                var minAngle = control.startAngle
                var maxAngle = control.endAngle
                var minValue = control.from
                var maxValue = control.to
                for (var value = minValue; value <= maxValue; value += 5) {
                    var angle = minAngle + (value - minValue) * (maxAngle - minAngle) / (maxValue - minValue)
                    var rad = (angle - 90) * Math.PI / 180
                    var tickLength = (value % 20 === 0) ? largeTickLength : smallTickLength
                    var xStart = centerX + (radius - tickLength) * Math.cos(rad)
                    var yStart = centerY + (radius - tickLength) * Math.sin(rad)
                    var xEnd = centerX + radius * Math.cos(rad)
                    var yEnd = centerY + radius * Math.sin(rad)
                    ctx.beginPath()
                    ctx.moveTo(xStart, yStart)
                    ctx.lineTo(xEnd, yEnd)
                    ctx.lineWidth = 2
                    ctx.strokeStyle = dialColor
                    ctx.stroke()
                    if (value % 20 === 0) {
                        var labelX = centerX + labelRadius * Math.cos(rad)
                        var labelY = centerY + labelRadius * Math.sin(rad)
                        ctx.fillStyle = dialColor
                        ctx.font = "bold 14px sans-serif"
                        ctx.textAlign = "center"
                        ctx.textBaseline = "middle"
                        ctx.fillText(value.toString(), labelX, labelY)
                    }
                }
            }
        }
    }

    // Current Temperature (Outer Dial)
    Shape {
        id: outer
        antialiasing: true
        visible: !setManualMode
        z: 3
        anchors.centerIn: parent
        width: control.width - 10
        height: width

        ShapePath {
            fillColor: "transparent"
            strokeColor: gradientColor
            strokeStyle: ShapePath.SolidLine
            strokeWidth: 8
            capStyle: control.capStyle
            pathHints: ShapePath.PathNonIntersecting

            PathAngleArc {
                id: outerArc
                centerX: parent.width / 2
                centerY: centerY
                radiusX: parent.width / 2 - 10
                radiusY: radiusX
                startAngle: control.startAngle - 90
                sweepAngle: control.currentAngle - control.startAngle

                Behavior on sweepAngle {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
            }
        }
    }

    CustomElipse {
        width: control.width
        height: control.height
        anchors.horizontalCenter: parent.horizontalCenter
        outerStrokeArea: outerHandleSize * 2
        onClicked: {}
    }

    // Set Temperature (Inner Dial)
    Shape {
        antialiasing: true
        z: 2
        anchors.centerIn: parent
        width: control.width - 10
        height: width

        ShapePath {
            id: outerShapePath
            fillColor: "transparent"
            strokeColor: control.currentColorSetPoint
            strokeStyle: ShapePath.SolidLine
            strokeWidth: 5
            capStyle: control.capStyle
            pathHints: ShapePath.PathNonIntersecting

            PathAngleArc {
                id: innerArc
                centerX: parent.width / 2
                centerY: centerX
                radiusX: parent.width / 4
                radiusY: radiusX
                startAngle: control.startAngle - 90
                sweepAngle: control.currentAngleSetPoint - control.startAngle
            }
        }
    }

    Item {
        width: parent.width / 2
        height: parent.height / 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Column {
            width: parent.width
            height: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            // Current Temperature Label
            Item {
                width: parent.width
                height: parent.height / 2
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalAlignment
                    height: parent.height
                    font.family: "Helvetica"
                    font.italic: false
                    font.pixelSize: height
                    fontSizeMode: Text.Fit
                    text: Math.round(currentTemp * 10) / 10 + "°"
                    color: control.gradientColor
                }
            }

            // Setpoint Temperature Label
            Rectangle {
                width: parent.width
                height: parent.height / 2
                color: 'transparent'
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalAlignment
                    height: parent.height
                    font.family: "Helvetica"
                    font.italic: false
                    font.pixelSize: height
                    fontSizeMode: Text.Fit
                    text: Math.round(setpointValue * 100 / 100) + suffixText
                    color: control.currentColorSetPoint
                }
            }
        }
    }

    Item {
        width: parent.width / 2
        height: parent.height / 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30

        Label {
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: control.labelText
            color: Constants.textColor
            font.bold: true
            font.pixelSize: height
        }
    }
}
