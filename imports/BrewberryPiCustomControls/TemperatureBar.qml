import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Controls.Material
import BrewberryPi

pragma ComponentBehavior: Bound

Dial {

    property int capStyle: Qt.RoundCap
    property color trackColor: "#505050"
    property color progressColor: "#3a4ec4"
    property color handleColor: "#fefefe"
    property real currentTemp: 0.0

    property real currentAngle: startAngle + (endAngle - startAngle) * (currentTemp - from) / (to - from)
    property color gradientColor: Qt.rgba((currentAngle - startAngle) / (endAngle - startAngle), 0, 1 - (currentAngle - startAngle) / (endAngle - startAngle), 1)
    property real currentAngleSetPoint: startAngle + (endAngle - startAngle) * (value - from) / (to - from)
    property color currentColorSetPoint: Qt.rgba((currentAngleSetPoint - startAngle) / (endAngle - startAngle), 0, 1 - (currentAngleSetPoint - startAngle) / (endAngle - startAngle), 1)

    property alias setpointValue: control.value
    signal valueChangedAndReleased(real setpointValue)

    id: control
    visible: true
    antialiasing: true

    background: Rectangle {
        // No background
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
        width: 30
        height: height
        anchors.centerIn: parent

        // Shadow effect
        Rectangle {
            width: handleItem.width / 2
            height: width
            radius: width / 2
            anchors.centerIn: parent
            color: control.pressed ? '#FFFFFF' : '#000000'
            border.width: 0
            z: 1
        }

        Rectangle {
            id: handleShadow
            width: handleItem.width
            height: width
            radius: width / 2
            color: currentColorSetPoint
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
                        opacity: 0.5
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
                y: -Math.min(control.background.width, control.background.height) * 0.3 + handleItem.height / 2
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

            var minAngle = -140; // Start angle in degrees
            var maxAngle = 140; // End angle in degrees
            var minValue = 0; // Start value
            var maxValue = 220; // End value

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
                ctx.strokeStyle = "black";
                ctx.stroke();

                // Draw labels for large tick marks
                if (value % 20 === 0) {
                    var labelX = centerX + labelRadius * Math.cos(rad);
                    var labelY = centerY + labelRadius * Math.sin(rad);
                    ctx.fillStyle = "black";
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

    // Set Temperatue Label
    Label {
        anchors.horizontalCenter: control.horizontalCenter
        anchors.verticalCenter: control.verticalCenter
        font {
            family: "Helvetica"
            italic: false
            pointSize: Constants.degSize + 24
        }
        text: control.value + "°"
        color: control.progressColor

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: 10
            font {
                family: "Helvetica"
                italic: false
                pointSize: Constants.degSize
            }
            text: "Target Temp"
            color: "black"
        }
    }

    // Current Temperature Label
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        font {
            family: "Helvetica"
            italic: false
            pointSize: Constants.degSize + 24
        }
        text: Math.round(currentTemp * 100 / 100) + "°"
        color: control.gradientColor

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: 10
            font {
                family: "Helvetica"
                italic: false
                pointSize: Constants.degSize
            }
            text: "Current Temp"
            color: "black"
        }
    }


}
