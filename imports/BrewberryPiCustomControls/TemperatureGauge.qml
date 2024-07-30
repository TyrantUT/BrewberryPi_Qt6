import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Controls.Material
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


    readonly property string suffixText: setManualMode ? "%" : "°"
    signal valueChangedAndReleased(real setpointValue)

    visible: true
    antialiasing: true

    // Defaults
    from: 0
    to: setManualMode ? 100 : 220
    stepSize: 1
    startAngle: -140
    endAngle: 140

    background: Rectangle {
        color: 'transparent'
    }

    onSetManualModeChanged: {
        canvas.requestPaint()
    }

    onPressedChanged: {
        // Toggle between states for the handle shadow
        if (handleShadow.state === "pressed") {
            handleShadow.state = "unpressed"
        } else {
            handleShadow.state = "pressed"
        }

        if (!pressed) {
            valueChangedAndReleased(value)
        }
    }

    onValueChanged: {
        if (!pressed) {
            valueChangedAndReleased(value)
        }
    }

    handle: Item {
        id: handleItem
        width: 20
        height: width * 2
        anchors.centerIn: parent
        visible: enabled

        // Shadow effect
        Rectangle {
            width: handleItem.width / 2
            height: width * 2
            radius: 5
            anchors.centerIn: parent
            border.width: 0
            z: 1
            color: Constants.backgroundColor
        }

        Rectangle {
            id: handleShadow
            width: handleItem.width
            height: width * 2
            radius: 10
            //color: currentColorSetPoint
            color: 'steelblue'
            anchors.centerIn: parent
            border.width: 0

            // Define initial state
            state: "unpressed"

            // Define states
            states: [
                State {
                    name: "pressed"
                    PropertyChanges {
                        target: handleShadow
                        opacity: 1.0
                    }
                },
                State {
                    name: "unpressed"
                    PropertyChanges {
                        target: handleShadow
                        opacity: 0.0
                    }
                }
            ]

            // Define transitions
            transitions: [
                Transition {
                    from: "unpressed"
                    to: "pressed"
                    SequentialAnimation {
                        NumberAnimation {
                            target: handleShadow
                            property: "opacity"
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                },
                Transition {
                    from: "pressed"
                    to: "unpressed"
                    SequentialAnimation {
                        NumberAnimation {
                            target: handleShadow
                            property: "opacity"
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            ]
        }

        transform: [
            Translate {
                y: -Math.min(control.background.width, control.background.height) * 0.5 + handleItem.height / 2
            },
            Rotation {
                angle: control.angle
                origin.x: handleItem.width / 2
                origin.y: handleItem.height / 2
            }
        ]
    }

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: control.width
        height: width

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var centerX = width / 2;
            var centerY = height / 2;
            var radius = Math.min(width, height) / 2 - (outerShapePath.strokeWidth * 2);
            var largeTickLength = 15; // Length of large tick arks
            var smallTickLength = 7;  // Length of small tick marks
            var labelRadius = radius - largeTickLength - 20; // Radius for the labels

            var minAngle = control.startAngle; // Start angle in degrees
            var maxAngle = control.endAngle; // End angle in degrees
            var minValue = control.from; // Start value
            var maxValue = control.to; // End value

            // Draw tick marks and labels
            for (var value = minValue; value <= maxValue; value += 5) {
                // Map value to angle
                var angle = minAngle + (value - minValue) * (maxAngle - minAngle) / (maxValue - minValue);
                // Convert angle to radians and shift by 90 degrees
                var rad = (angle - 90) * Math.PI / 180;
                var tickLength = (value % 20 === 0) ? largeTickLength : smallTickLength;
                var xStart = centerX + (radius - tickLength) * Math.cos(rad);
                var yStart = centerY + (radius - tickLength) * Math.sin(rad);
                var xEnd = centerX + radius * Math.cos(rad);
                var yEnd = centerY + radius * Math.sin(rad);

                ctx.beginPath();
                ctx.moveTo(xStart, yStart);
                ctx.lineTo(xEnd, yEnd);
                ctx.lineWidth = 2;
                ctx.strokeStyle = dialColor;
                ctx.stroke();

                // Draw labels for large tick marks
                if (value % 20 === 0) {
                    var labelX = centerX + labelRadius * Math.cos(rad);
                    var labelY = centerY + labelRadius * Math.sin(rad);
                    ctx.fillStyle = dialColor;
                    ctx.font = "bold 14px sans-serif";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText(value.toString(), labelX, labelY);
                }
            }
        }
    }

    // Current Temperature (Outer Dial)
    Shape {
        id: outer
        antialiasing: true

        ShapePath {
            fillColor: "transparent"
            strokeColor: gradientColor
            strokeStyle: ShapePath.SolidLine
            strokeWidth: 10
            capStyle: ShapePath.RoundCap
            pathHints: ShapePath.PathNonIntersecting

            PathAngleArc {
                id: outerArc
                centerX: control.width / 2
                centerY: centerX
                radiusX: control.width / 2
                radiusY: radiusX
                startAngle: control.startAngle - 90
                sweepAngle: currentAngle + control.endAngle
            }
        }
    }

    // Set Temperature (Inner Dial)
    Shape {
        antialiasing: true

        ShapePath {
            id: outerShapePath
            fillColor: "transparent"
            strokeColor: control.currentColorSetPoint
            strokeStyle: ShapePath.SolidLine

            strokeWidth: 5
            capStyle: ShapePath.RoundCap
            pathHints: ShapePath.PathNonIntersecting

            PathAngleArc {
                id: innerArc
                centerX: control.width / 2
                centerY: centerX
                radiusX: control.width / 4
                radiusY: radiusX
                startAngle: control.startAngle - 90
                sweepAngle: control.angle + control.endAngle
            }
        }
    }

    Item {
        width: parent.width / 2
        height: parent.height / 2
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

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
                    font {
                        family: "Helvetica"
                        italic: false
                        pixelSize: height
                    }
                    fontSizeMode: Text.Fit
                    text: Math.round(currentTemp * 100 / 100) + "°"
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
                    font {
                        family: "Helvetica"
                        italic: false
                        pixelSize: height
                    }
                    fontSizeMode: Text.Fit
                    text: Math.round(control.value * 100 / 100) + suffixText
                    color: control.currentColorSetPoint
                }
            }
        }
    }

    Item {
        width: parent.width / 2
        height: parent.height / 20
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 30
        }
        Label {
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:  parent.bottom
            text: control.labelText
            color: Constants.textColor
            font.bold: true
            font.pixelSize: height
        }
    }
}
