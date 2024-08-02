import QtQuick
import QtQuick.Controls
import BrewberryPi

Item {

    property real currentTemp: 0.0
    property real setpointTemp: 0.0
    property var dataPoints: []
    property int maxPoints: 100

    Connections {
        target: Constants
        function onIsDarkThemeChanged() {
            canvas.requestPaint();
        }
    }

    onSetpointTempChanged: {
        canvas.requestPaint();
    }

    Canvas {
        id: canvas
        width: parent.width
        height: parent.height

        onPaint: {
            var ctx = canvas.getContext("2d");
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // Define margins and axis positions
            var xAxisPosition = canvas.height - 30;
            var yAxisPosition = 50;
            var graphWidth = canvas.width - 2 * yAxisPosition;
            var graphHeight = canvas.height - 2 * yAxisPosition;
            var maxYValue = 220;

            // Calculate the Y-axis length
            var yAxisLength = xAxisPosition - yAxisPosition;

            // Draw X and Y axes
            ctx.strokeStyle = "#000000"; // Axis color
            ctx.lineWidth = 1;

            // Draw X axis
            ctx.beginPath();
            ctx.moveTo(yAxisPosition, xAxisPosition); // Position X axis
            ctx.lineTo(canvas.width - yAxisPosition, xAxisPosition);
            ctx.stroke();

            // Draw Y axis
            ctx.beginPath();
            ctx.moveTo(yAxisPosition, yAxisPosition); // Start of Y axis
            ctx.lineTo(yAxisPosition, xAxisPosition); // End of Y axis
            ctx.stroke();

            // Draw the line graph
            if (dataPoints.length > 0) {
                ctx.beginPath();
                ctx.moveTo(yAxisPosition, xAxisPosition - (dataPoints[0].y / maxYValue) * yAxisLength);

                for (var i = 1; i < dataPoints.length; i++) {
                    var x = yAxisPosition + i * graphWidth / (maxPoints - 1);
                    var y = xAxisPosition - (dataPoints[i].y / maxYValue) * yAxisLength;
                    ctx.lineTo(x, y);
                }

                ctx.strokeStyle = "#3498db"; // Line color
                ctx.lineWidth = 2;
                ctx.stroke();
            }

            // Draw X axis labels
            ctx.fillStyle = Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor
            ctx.font = "10px Arial";
            for (var i = 0; i <= maxPoints; i += 10) {
                var x = yAxisPosition + i * graphWidth / (maxPoints - 1);
                ctx.fillText(i, x - 10, xAxisPosition + 15); // Position below the X axis
            }

            // Draw Y axis labels and tick marks
            ctx.font = "10px Arial";
            for (var i = 0; i <= maxYValue; i += 10) { // Avoid drawing beyond the maxYValue
                var y = xAxisPosition - (i / maxYValue) * yAxisLength;
                ctx.fillText(i, yAxisPosition - 35, y + 5); // Position to the left of the Y axis

                // Draw large tick marks every 10 degrees
                ctx.beginPath();
                ctx.moveTo(yAxisPosition - 10, y);
                ctx.lineTo(yAxisPosition, y);
                ctx.stroke();

                // Draw small tick marks every 5 degrees
                if (i % 10 === 0) {
                    for (var j = 5; j < 10; j += 5) {
                        var smallTickY = xAxisPosition - ((i + j) / maxYValue) * yAxisLength;
                        if (smallTickY >= yAxisPosition) { // Ensure tick mark is within the axis range
                            ctx.beginPath();
                            ctx.moveTo(yAxisPosition - 5, smallTickY);
                            ctx.lineTo(yAxisPosition, smallTickY);
                            ctx.stroke();
                        }
                    }
                }
            }

            // Draw dashed light red line based on setpointTemp on the Y axis
            var setpointY = xAxisPosition - (setpointTemp / maxYValue) * yAxisLength;
            ctx.strokeStyle = "#FFAAAA"; // Light red color
            ctx.lineWidth = 1;
            ctx.setLineDash([5, 5]); // Dashed line pattern

            ctx.beginPath();
            ctx.moveTo(yAxisPosition, setpointY); // Start of dashed line
            ctx.lineTo(canvas.width - yAxisPosition, setpointY); // End of dashed line
            ctx.stroke();

            ctx.setLineDash([]); // Reset to solid line
        }
    }

    Timer {
        interval: 1000 // Update every second
        running: true
        repeat: true
        onTriggered: {
            // Add the current temperature to the data points
            if (dataPoints.length >= maxPoints) {
                dataPoints.shift(); // Remove the oldest value
            }
            dataPoints.push({x: dataPoints.length * (canvas.width / maxPoints), y: currentTemp});
            canvas.requestPaint();
        }
    }

}
