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
    property bool suppressAnimation: false

    signal valueChangedAndReleased(real setpointValue)

    onSetManualModeChanged: {
        suppressAnimation = true
        canvas.requestPaint()
        Qt.callLater(function() { suppressAnimation = false })
    }

    onPressedChanged: {
        if (!pressed) {
            valueChangedAndReleased(setpointValue)
        }
    }

    Connections {
        target: Constants
        function onIsDarkThemeChanged() {
            canvas.requestPaint()
        }
    }

    visible: true
    antialiasing: true
    from: 0
    to: setManualMode ? 100 : 220
    stepSize: 10
    startAngle: -140
    endAngle: 140
    inputMode: Dial.Circular
    wrap: false

    background: Item {
        width: control.width
        height: control.height
        anchors.centerIn: parent

        Shape {
            id: shell
            width: parent.width - 5
            height: parent.height - 5
            anchors.centerIn: parent

            ShapePath {
                id: shellShapePath
                fillColor: Constants.isDarkTheme ? Qt.darker(Constants.backgroundColor, 1.6) : Qt.lighter(Constants.backgroundColor, 1.6)
                strokeColor: Constants.isDarkTheme ? Qt.lighter(Constants.backgroundColor, 2.0) : Qt.darker(Constants.backgroundColor, 1.6)
                strokeWidth: 3
                capStyle: Qt.RoundCap

                // Start before startAngle at -150°
                startX: shell.width / 2 + ((shell.width - shellShapePath.strokeWidth) / 2) * Math.cos(((startAngle - 10) - 90) * Math.PI / 180)
                startY: shell.height / 2 + ((shell.height - strokeWidth) / 2) * Math.sin(((startAngle - 10) - 90) * Math.PI / 180)
                PathArc {
                    x: shell.width / 2 + ((shell.width - shellShapePath.strokeWidth) / 2) * Math.cos(((endAngle + 10) - 90) * Math.PI / 180)
                    y: shell.height / 2 + ((shell.height - shellShapePath.strokeWidth) / 2) * Math.sin(((endAngle + 10) - 90) * Math.PI / 180)
                    radiusX: (shell.width - shellShapePath.strokeWidth) / 2
                    radiusY: (shell.height - shellShapePath.strokeWidth) / 2
                    useLargeArc: true
                }
                // Upward-pointing trapezoidal cutout with outward-angled sides


                PathLine {
                    x: shell.width / 2 + ((shell.width - shellShapePath.strokeWidth) / 2) * Math.cos(((startAngle - 10) - 90) * Math.PI / 180)
                    y: shell.height / 2 + ((shell.height - shellShapePath.strokeWidth) / 2) * Math.sin(((startAngle - 10) - 90) * Math.PI / 180)
                }
            }
        }

        MultiEffect {
            anchors.fill: shell
            source: shell
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.6) // Darker shadow for stronger contrast
            shadowOpacity: 1.0 // Full opacity for prominence
            shadowBlur: 1.0 // Increased blur for softer, elevated look
            shadowHorizontalOffset: 8 // Top-left lighting
            shadowVerticalOffset: 8
            shadowScale: 0.95 // Tighter shadow for pop-out effect
            blurEnabled: true
            blur: 0.6 // Slightly increased for smoothness
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


                    var gradient = ctx.createLinearGradient(xStart, yStart, xEnd, yEnd)
                    gradient.addColorStop(0.0, Qt.lighter(control.dialColor, 1.5))
                    gradient.addColorStop(0.5, control.dialColor)
                    gradient.addColorStop(1.0, Qt.darker(control.dialColor, 1.3))
                    ctx.beginPath()
                    ctx.moveTo(xStart, yStart)
                    ctx.lineTo(xEnd, yEnd)
                    ctx.lineWidth = (value % 20 === 0) ? 4 : 3
                    ctx.lineCap = "butt"
                    ctx.strokeStyle = gradient
                    ctx.stroke()

                    if (value % 20 === 0) {
                        var labelX = centerX + labelRadius * Math.cos(rad)
                        var labelY = centerY + labelRadius * Math.sin(rad)
                        ctx.fillStyle = control.dialColor
                        ctx.font = "bold 14px sans-serif"
                        ctx.textAlign = "center"
                        ctx.textBaseline = "middle"
                        ctx.fillText(value.toString(), labelX, labelY)
                    }
                }
            }
        }
    }

    Shape {
        id: outer
        antialiasing: true
        visible: !setManualMode

        ShapePath {
            fillColor: "transparent"
            strokeColor: gradientColor
            strokeStyle: ShapePath.SolidLine
            strokeWidth: 15
            capStyle: ShapePath.FlatCap
            pathHints: ShapePath.PathNonIntersecting

            PathAngleArc {
                id: outerArc
                centerX: control.width / 2
                centerY: centerX
                radiusX: (control.width / 2) - 20
                radiusY: radiusX
                startAngle: control.startAngle - 90
                sweepAngle: currentAngle - control.startAngle

                Behavior on sweepAngle {
                    enabled: !control.suppressAnimation

                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
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
            id: label
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: control.labelText
            color: Qt.lighter(Constants.textColor, 1.6)
            font.bold: true
            font.pixelSize: height

            MultiEffect {
                    anchors.fill: label
                    source: label
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.6)
                    shadowOpacity: 0.9
                    shadowBlur: 2.0
                    shadowHorizontalOffset: 2
                    shadowVerticalOffset: 2

                    blurEnabled: false
                }
        }
    }
}
