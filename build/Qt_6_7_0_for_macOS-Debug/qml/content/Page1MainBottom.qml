import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Item {
    Rectangle {
        height: parent.height
        width: parent.width
        color: Constants.backgroundColor
    }
    Row {
        spacing: 2
        width: parent.width / 3
        height: parent.height

        // HLT Column
        Column {
            width: parent.width
            height: parent.height

            Row {
                width: parent.width
                height: parent.height

                Item {
                    height: parent.height
                    width: parent.width

                    Switch {
                        id: switch_setpointManual_HLT
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        rotation: -90
                        checked: BreweryValues.setpointManual_HLT

                        onCheckedChanged: {
                            if (BreweryValues.setpointManual_HLT !== checked) {
                                BreweryValues.setpointManual_HLT = checked;
                            }
                        }
                    }

                    Text {
                        text: switch_setpointManual_HLT.checked ? 'Manual' : 'Automatic'
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: switch_setpointManual_HLT.bottom
                        anchors.topMargin: 20
                        color: Constants.textColor
                        font.pixelSize: height
                        font.bold: true
                    }
                }
            }
        }
    }
}
