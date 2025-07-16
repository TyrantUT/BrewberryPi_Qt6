import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Page {
    property real testTemperature: 15 // Initial temperature

    CustomLineGraph {
        id: hltGraph
        width: 200
        height: 50
        anchors.centerIn: parent
        maxTemperature: 215
        timeWindow: 30
        maxPoints: 100
        currentTemperature: BreweryValues.currentTemp_HLT
        running: true
    }

    Timer {
        interval: 500 // Update every 500ms
        running: true
        repeat: true
        onTriggered: {
          // Simulate realistic temperature changes (50–200°F)
          var variation = (Math.random() - 0.5) * 10 // Small random variation
          testTemperature = Math.max(50, Math.min(200, testTemperature + variation))
        }
    }

    Text {
        anchors {
            bottom: hltGraph.top
            horizontalCenter: hltGraph.horizontalCenter
            bottomMargin: 10
        }
        text: "HLT Temperature (°F)"
        font.pixelSize: 16
        color: "#ffffff"
    }
}
