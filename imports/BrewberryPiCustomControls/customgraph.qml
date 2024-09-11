import QtQuick
import QtQuick.Layouts
import QtCharts
import QtQuick.Controls

Item {
    id: root

    property string chartLabel: "";
    property int chartXFontSize: 6
    property int chartYFontSize: 6
    property int chartYSpacing: 20
    property int numpoints: 1000;
    property int interval: 100;
    property real step: 0.01;
    property real currentTemp: 0.0;
    property real setpointTemp: 0.0;

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

    function draw(xax, yax, lineSeries, dataPoint) {
        lineSeries.remove(0);
        xax.min = xax.min + step;
        xax.max = xax.max + step;

        var x = lineSeries.at(lineSeries.count - 1).x + step ;
        lineSeries.append(x, dataPoint);
        if (dataPoint > yax.max){
            yax.max = dataPoint + 1;
        } else if (dataPoint < yax.min){
            yax.min = dataPoint - 1;
        }
    }

    ChartView {
        width: root.width
        height: root.height
        Layout.fillHeight: true
        Layout.fillWidth: true
        title: root.chartLabel
        titleColor: "white"
        antialiasing: true
        legend.visible: false
        backgroundColor: "black"

        CategoryAxis {
            id: xAxis
            min: 0
            max: numpoints * step + (numpoints * step) / 6;
            gridVisible: false
            lineVisible: false
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue;
            labelsColor: 'white'
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
            lineVisible: false
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue;
            labelsColor: 'white'
            labelsFont:Qt.font({pointSize: root.chartYFontSize})
        }

        LineSeries {
            id: lineSeries
            axisX: xAxis
            axisY: yAxis

            Component.onCompleted: {
                for (var i = 0; i < numpoints; i++) {
                    lineSeries.append(i*step, root.currentTemp); // Dynamically updated within the timer
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
            labelsColor: 'white'
            labelsFont:Qt.font({pointSize: root.chartYFontSize})
            gridLineColor: "#ff0000"
            minorGridVisible: false

           CategoryRange {
               label: "Mash"
               endValue: 152
           }

           CategoryRange {
               label: "Strike"
               endValue: 168
           }

           CategoryRange {
               label: "Boil"
               endValue: 212
           }

            Component.onCompleted: {
                for (var i = 0; i < max + 1; i++) {
                    if (i == 152) { yAxis.append(("<span style=\" color:#ff0000;\">152°</span>"), i); }
                    if (i == 168) { yAxis.append(("<span style=\" color:#ff0000;\">168°</span>"), i); }
                    if (i == 212) { yAxis.append(("<span style=\" color:#ff0000;\">212°</span>"), i); }
                    if (i % root.chartYSpacing === 0) {yAxis.append( i + "&deg", i ); }
                }
            }
        }

        LineSeries {
            id: lineSeries2
            axisX: xAxis2
            axisY: yAxis2
        }

        Label {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 10
            }

            text: qsTr("Current Temperature: " + Math.round(currentTemp, 1))
            color: "#FFFFFF"
            font.pointSize: 15
        }
    }


}

