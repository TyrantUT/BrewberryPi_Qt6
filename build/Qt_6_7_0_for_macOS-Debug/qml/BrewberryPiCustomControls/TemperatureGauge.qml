import QtQuick
import QtQuick.Shapes

pragma ComponentBehavior: Bound

Item {
    id: control
    property real currentTemperature: 25
    property real targetTemperature: currentTemperature
    property real maxTemperature: 220

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        color: "transparent"

        // Arc for temperature
        Canvas {
            id: gaugeArcCanvas
            anchors.fill: parent
            anchors.margins: 15

            onPaint: {
                var ctx = gaugeArcCanvas.getContext("2d")
                var radius = control.width / 6
                var centerX = gaugeArcCanvas.width / 2
                var centerY = gaugeArcCanvas.height / 2

                // Clear previous drawing
                ctx.clearRect(0, 0, gaugeArcCanvas.width, gaugeArcCanvas.height)

                // Draw temperature arc
                var startAngle = -Math.PI / 2
                var endAngle = startAngle + (currentTemperature / maxTemperature) * 2 * Math.PI
                ctx.strokeStyle = "steelblue"
                ctx.lineWidth = 15
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius - 20, startAngle, endAngle)
                ctx.stroke()
            }
        }

        // Inner circle with shadow
        Rectangle {
            width: control.width / 4
            height: width
            color: "#ffffff"
            radius: width / 2
            anchors.centerIn: parent
            border.color: "#888888"
            border.width: 2
        }

        // Temperature label
        Text {
            id: tempText
            text: currentTemperature + "°F"
            font.pixelSize: 40
            anchors.centerIn: parent
            color: "black"
        }
    }

    onCurrentTemperatureChanged: {
        gaugeArcCanvas.requestPaint()
    }
}
