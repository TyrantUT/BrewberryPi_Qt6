import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BrewberryPi
import BrewberryPiCustomControls

Page {
    id: stackLayoutHlt
    height: Constants.height
    width: Constants.width

    Rectangle {
        id: mainRectangle
        anchors.fill: parent
        color: Constants.backgroundColor

        Rectangle {
            id: subParent
            height: parent.height
            width: parent.width / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: parent.color

            RadialBar {
                id: radialHLT
                width: parent.width
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                penStyle: Qt.RoundCap
                progressColor: Constants.progressColor
                backgroundColor: Constants.backgroundColor
                foregroundColor: Constants.foregroundColor
                setPointTextColor: Constants.setPointTextColor
                setPointBarColor: Constants.setPointBarColor
                dialWidth: Constants.dialWidth
                minValue: Constants.minVal
                maxValue: Constants.maxVal
                pointValue: BreweryValues.setpoint_HLT
                value: 150
                suffixText: Constants.tempBarSuffix
                textFont {
                    family: "Helvetica"
                    italic: false
                    pointSize: Constants.degSize + 24
                }
                textColor: Constants.tempColor
            }
        }

        Rectangle {
            width: parent.width / 3
            height: 25
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 16

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: slider_HLTSetPoint.top
                anchors.bottomMargin: 10
                font.pointSize: Constants.labelSize + 10
                color: Constants.radialBarLabelColor
                text: qsTr("Target Temperature")
            }

            Slider {
                id: slider_HLTSetPoint
                anchors.fill: parent
                orientation: Qt.Horizontal
                from: Constants.minVal
                to: Constants.maxVal
                value: BreweryValues.setpoint_HLT
                stepSize: 0.5

                onValueChanged: {
                    if (value !== BreweryValues.setpoint_HLT) {
                        BreweryValues.setpoint_HLT = value;
                    }
                }

            }
        }
    }
}
