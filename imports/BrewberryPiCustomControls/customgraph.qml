import QtQuick
import QtCharts
import BrewberryPi

ChartView {
    id: chartView
    width: 800
    height: 600

    title: "Real-Time Temperature Chart"
    legend.visible: false
    antialiasing: true

    LineSeries {
        id: lineSeries
        name: "Temperature"

        // Define the X and Y axes
        axisX: ValuesAxis {
            id: xAxis
            min: 0
            max: 120 // Will be updated dynamically
            tickCount: 6
            titleText: "Time (minutes)" // X-axis label
        }

        axisY: ValuesAxis {
            id: yAxis
            min: 0
            max: 220 // Adjust according to your temperature range
            tickCount: 10
            titleText: "Temperature" // Y-axis label
        }

        // Function to update the series with new temperature value
        function addTemperature(value, timeIndex) {
            // Add new value
            lineSeries.append(timeIndex, value);

            // Remove old values if count exceeds 120 points
            if (lineSeries.count > 120) {
                lineSeries.remove(0); // Remove the oldest value
            }

            // Update X-axis min and max
            if (lineSeries.count > 0) {
                xAxis.min = lineSeries.at(0).x; // Set min to the time of the earliest value
                xAxis.max = xAxis.min + 120; // Set max to 120 seconds ahead of min
            }
        }
    }

    Timer {
        id: timer
        interval: 1000 // Update every second
        running: true
        repeat: true

        property int elapsedTime: 0 // Counter to track elapsed time in seconds

        onTriggered: {
            var newTemperature = Math.random() * 30 + 10; // Simulate new temperature reading
            lineSeries.addTemperature(newTemperature, elapsedTime);
            elapsedTime++; // Increment the elapsed time
        }
    }
}
