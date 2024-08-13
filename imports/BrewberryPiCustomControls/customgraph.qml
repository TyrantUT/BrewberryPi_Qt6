import QtQuick
import QtCharts
import BrewberryPi

pragma ComponentBehavior: Bound

ChartView {
    id: chartView
    legend.visible: false
    antialiasing: true
    backgroundColor: Constants.backgroundColor
    titleColor: Constants.textColor
    animationOptions: ChartView.SeriesAnimations
    dropShadowEnabled: true

    property real setpointTemp: 0.0

    onSetpointTempChanged: {
        setpointSeries.remove(0); // Remove the oldest point
        setpointSeries.remove(0); // Remove the oldest point
        setpointSeries.append(xAxis.min, setpointTemp);
        setpointSeries.append(new Date(xAxis.min.getTime() + 120000), setpointTemp);
    }

    LineSeries {
        id: lineSeries
        name: "Temperature"

        // Define the X and Y axes
        axisX: DateTimeAxis {
            id: xAxis
            min: new Date(0) // Initial min value; will be updated dynamically
            max: new Date(120000) // Initial max value; 120 seconds in milliseconds
            format: "mm:ss" // Format for the labels
            tickCount: 5
            titleText: "Time (minutes)" // X-axis labe
            labelsColor: Constants.textColor
            labelsFont: Qt.font({bold: true})
            gridVisible: false
            titleBrush: labelsColor
        }

        axisY: ValuesAxis {
            id: yAxis
            min: 0
            max: 220 // Adjust according to your temperature range
            tickCount: chartView.height / 50
            titleText: "Temperature" // Y-axis label
            labelFormat: "%d &deg;F"
            labelsColor: Constants.textColor
            labelsFont: Qt.font({bold: true})
            gridVisible: false
            titleBrush: labelsColor
        }

        // Function to update the series with new temperature value
        function addTemperature(value, timestamp) {
            // Add new value
            lineSeries.append(timestamp, value);

            // Remove old values if count exceeds 120 points
            if (lineSeries.count > 5) {
                //lineSeries.remove(0); // Remove the oldest value
                lineSeries.removePoints(0, 1);
            }

            // Update X-axis min and max
            if (lineSeries.count > 0) {
                var firstPointTime = lineSeries.at(0).x;
                xAxis.min = new Date(firstPointTime);
                xAxis.max = new Date(xAxis.min.getTime() + 120000); // Set max to 120 seconds ahead of min
            }
        }
    }

    LineSeries {
        id: setpointSeries
        name: "Setpoint Temperature"
        axisX: xAxis
        axisY: yAxis
        color: "red" // Set the color to red
        width: 1 // Line width
        style: Qt.DashLine // Dashed line style

        // This series will be used to create a dashed line
        // Initialize with dummy data
        Component.onCompleted: {
            // Initialize with dummy data
            var initialTime = xAxis.min;
            setpointSeries.append(initialTime, setpointTemp);
            setpointSeries.append(new Date(initialTime.getTime() + 120000), setpointTemp);
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
            var currentTime = new Date(); // Current time
            var timestamp = new Date(elapsedTime * 1000); // Timestamp with elapsed time
            lineSeries.addTemperature(newTemperature, timestamp);
            elapsedTime++; // Increment the elapsed time
        }
    }
}
