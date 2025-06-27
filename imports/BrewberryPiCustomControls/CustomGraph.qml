import QtQuick
import QtQuick.Layouts
import QtCharts
import QtQuick.Controls
import BrewberryPi

Item {
    id: root

    property string chartLabel: "";
    property int chartXFontSize: 10
    property int chartYFontSize: 6
    property int chartYSpacing: 20
    property int numpoints: 250;
    property int interval: 100;
    property real step: 0.01;
    property real currentTemp: 0.0;
    property real setpointTemp: 0.0;
    property string hintLineText: "";
    property double hintLineValue: 0.0;

    Timer {
        id: timer;
        interval: root.interval;
        repeat: true;
        running: true
        onTriggered: {
            draw(xAxis, yAxis, lineSeries, step, numpoints, root.currentTemp);

            if (xAxis.max - xAxis.categoriesLabels[xAxis.categoriesLabels.length - 1] > 1){
                xAxis.append(xAxis.max.toFixed(0), xAxis.max);
                xAxis.remove(xAxis.categoriesLabels[0]);
            }
        }
    }

    function draw(xAxis, yAxis, lineSeries, step, numpoints, currentTemp) {
        if (lineSeries.count < numpoints) {
            var x = lineSeries.count * step;
            lineSeries.append(x, currentTemp);

            if (lineSeries.count === numpoints) {
                xAxis.min = 0;
                xAxis.max = step * numpoints;
            }
        } else {
            lineSeries.remove(0);

            xAxis.min += step;
            xAxis.max += step;

            var lastX = lineSeries.at(lineSeries.count - 1).x;
            var xv = lastX + step;
            lineSeries.append(xv, currentTemp);
        }

        if (currentTemp > yAxis.max) {
            yAxis.max = currentTemp + 1;
        } else if (currentTemp < yAxis.min) {
            yAxis.min = currentTemp - 1;
        }
    }

    // Update the last data point in real-time when the value changes
    function updateLastDataPoint(lineSeries, currentTemp) {
        if (lineSeries.count > 0) {
            // Ensure the new value is a valid number
            if (isFinite(currentTemp)) {
                var lastIndex = lineSeries.count - 1;
                lineSeries.replace(lastIndex, lineSeries.at(lastIndex).x, currentTemp);
            }
        }
    }

    // Monitor currentTemp changes in real-time
    Connections {
        target: root

        function onCurrentTempChanged(value) {
            // Update the last point in real-time whenever currentTemp changes
            updateLastDataPoint(lineSeries, value);
        }
    }

    Rectangle {
        width: parent.width
        height: parent.height
        color: "#000000"
        opacity: .2
        radius: 5
        z: -1
    }

    ChartView {
        anchors.fill: parent
        margins {
            top: 0
            bottom: 0
            left: 0
            right: 10
        }
        antialiasing: true
        legend.visible: false
        backgroundRoundness: 0
        title: root.chartLabel
        titleColor: Constants.textColor
        backgroundColor: Constants.backgroundColor
        animationOptions: ChartView.SeriesAnimations

        CategoryAxis {
            id: xAxis
            min: 0
            max: numpoints * step + (numpoints * step) / 6;
            gridVisible: false
            minorGridVisible: false
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue;
            labelsColor: Constants.textColor
            labelsFont:Qt.font({pointSize: root.chartXFontSize})

            // Draw X Axis Labels
            Component.onCompleted: {
                for (var i = 0; i < max + 1; i++){
                    xAxis.append(i, i);
                }
            }
        }

        CategoryAxis {
            id: yAxis
            min: 0
            max: 220
            gridVisible: false
            minorGridVisible: false
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue;
            labelsColor: Constants.textColor
            labelsFont:Qt.font({pointSize: root.chartYFontSize})

            // Draw Y Axis Labels
            Component.onCompleted: {
                for (var i = 0; i < max + 1; i++) {
                    if (i % root.chartYSpacing === 0) {
                        yAxis.append( i + "&deg", i );
                    }
                }
            }
        }

        LineSeries {
            id: lineSeries
            axisX: xAxis
            axisY: yAxis
        }

        CategoryAxis {
            id: xAxis2
            gridVisible: false
            lineVisible: false
        }

        CategoryAxis {
            id: yAxis2
            min: 0
            max: 230
            gridLineColor: "#ff0000"
            gridVisible: true

           Component.onCompleted: {
               for (var i = 0; i < max; i++) {
                   if (i === root.hintLineValue) {
                       yAxis2.append("", i);
                   }
               }
           }
        }

        LineSeries {
            id: lineSeries2
            axisX: xAxis2
            axisY: yAxis2
        }
    }
}

