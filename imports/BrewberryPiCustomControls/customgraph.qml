import QtQuick
import QtQuick.Layouts
import QtCharts
import QtQuick.Controls
import BrewberryPi

Item {
    id: root

    property string chartLabel: "";
    property int chartXFontSize: 6
    property int chartYFontSize: 4
    property int chartYSpacing: 20
    property int numpoints: 1000;
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
        onTriggered: {
            draw(xAxis, yAxis, lineSeries, root.currentTemp);

            if (xAxis.max - xAxis.categoriesLabels[xAxis.categoriesLabels.length - 1] > 1){
                xAxis.append(xAxis.max.toFixed(0), xAxis.max);
                xAxis.remove(xAxis.categoriesLabels[0]);
            }
        }
    }

    function draw(xAxis, yAxis, lineSeries, dataPoint) {
        lineSeries.remove(0);
        xAxis.min = xAxis.min + step;
        xAxis.max = xAxis.max + step;

        var x = lineSeries.at(lineSeries.count - 1).x + step;
        lineSeries.append(x, dataPoint);
        if (dataPoint > yAxis.max){
            yAxis.max = dataPoint + 1;
        } else if (dataPoint < yAxis.min){
            yAxis.min = dataPoint - 1;
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
            right: 0
        }
        antialiasing: true
        legend.visible: false
        backgroundRoundness: 0
        title: root.chartLabel
        titleColor: Constants.textColor
        backgroundColor: Constants.backgroundColor

        CategoryAxis {
            id: xAxis
            min: 0
            max: numpoints * step + (numpoints * step) / 6;
            gridVisible: false
            minorGridVisible: true
            labelsColor: Constants.textColor
            labelsFont:Qt.font({pointSize: root.chartXFontSize})

            Component.onCompleted: {
                for (var i = 0; i < max + 1; i++){
                    xAxis.append(i, i);
                }
            }
        }

        CategoryAxis {
            id: yAxis
            min: 0
            max: 230
            gridVisible: false
            minorGridVisible: true
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue;
            labelsColor: Constants.textColor
            labelsFont:Qt.font({pointSize: root.chartYFontSize})

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

            Component.onCompleted: {
                for (var i = 0; i < numpoints; i++) {
                    lineSeries.append(i * step, root.currentTemp); // Dynamically updated within the timer
                }
                timer.start();
            }
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
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue;
            labelsColor: Constants.textColor
            labelsFont:Qt.font({pointSize: root.chartYFontSize})
            gridLineColor: "#ff0000"
            gridVisible: true

           CategoryRange {
               label: root.hintLineText
               endValue: root.hintLineValue
           }

           Component.onCompleted: {
               for (var i = 0; i < max; i++) {
                   if (i === root.hintLintValue) {
                       yAxis2.append((`<span style=\" color:#ff0000;\">${root.hintLineValue}&deg</span>`), i);
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

