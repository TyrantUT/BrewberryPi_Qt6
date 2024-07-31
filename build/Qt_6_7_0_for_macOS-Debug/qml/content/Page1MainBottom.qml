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
                width: parent.width / 2
                height: parent.height

                Item {
                    width: parent.width
                    height: parent.height

                    Column {
                        width: parent.width
                        height: parent.height
                        spacing: 15

                        Text {
                            text: 'PID Mode'
                            anchors.horizontalCenter: switch_setpointManual_HLT.horizontalCenter
                            color: Constants.textColor
                            font.pixelSize: height
                            font.bold: true
                        }

                        Switch {
                            id: switch_setpointManual_HLT
                            width: parent.width
                            anchors.horizontalCenter: parent.horizontalCenter
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
                            color: Constants.textColor
                            font.pixelSize: height
                            font.bold: true
                        }
                    }
                }

                Item {
                    width: parent.width / 2
                    height: parent.height

                    CustomDelayButton {
                        width: parent.width
                        height: parent.height
                        anchors.left: parent.left
                    }
                }
            }
        }
    }
}
