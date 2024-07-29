import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BrewberryPi
import BrewberryPiCustomControls

Page {
    id: page
    property int headerHeight: 50
    property int columnWidth: width / 2
    property int headerMargin: 10

    // Main container
    Rectangle {
        width: parent.width
        height: parent.height

        Rectangle {
            id: header
            height: headerHeight
            width: parent.width
            Label {
                text: qsTr("Brewery Status")
                font.bold: true
                font.pixelSize: 24
                anchors.centerIn: parent
            }
        }

        Column {
            spacing: 2
            width: parent.width
            height: (parent.height - headerHeight) / 3
            anchors.top: header.bottom

            Rectangle {
                width: parent.width
                height: 1
                color: 'black'
            }

            Row {
                spacing: 1
                width: parent.width / 3
                height: parent.height / 2

                TemperatureGauge {
                    width: parent.width
                    height: width
                    currentTemp: BreweryValues.currentTemp_HLT
                    setpointValue: BreweryValues.setpointTemp_HLT
                    enabled: false
                }
                TemperatureGauge {
                    width: parent.width
                    height: width
                    currentTemp: BreweryValues.currentTemp_Mash
                    setpointValue: BreweryValues.setpointTemp_Mash
                    enabled: false
                }
                TemperatureGauge {
                    width: parent.width
                    height: width
                    currentTemp: BreweryValues.currentTemp_Boil
                    setpointValue: BreweryValues.setpointTemp_Boil
                    enabled: false
                }
            }
        }

        Rectangle {
            id: footer
            width: parent.width
            height: parent.height / 3
            anchors.bottom: parent.bottom

            Column {
                spacing: 2
                width: parent.width
                height: parent.height
                anchors.bottom: footer.bottom

                Rectangle {
                    width: parent.width
                    height: 1
                    color: 'black'
                }

                Row {
                    width: parent.width
                    height: parent.height
                    spacing: 2

                    // HLT Status
                    Rectangle {
                        width: parent.width / 3
                        height: parent.height
                        // HLT
                        Column {
                            width: parent.width
                            height: parent.height
                            Rectangle {
                                width: parent.width
                                height: parent.height
                                Label {
                                    text: qsTr('HLT')
                                    font.bold: true
                                    font.pixelSize: 24
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: 'black'
                                }
                            }
                        }
                    }
                    // Mash Status
                    Rectangle {
                        width: parent.width / 3
                        height: parent.height
                        // HLT
                        Column {
                            width: parent.width
                            height: parent.height
                            Rectangle {
                                width: parent.width
                                height: parent.height
                                Label {
                                    text: qsTr('Mash')
                                    font.bold: true
                                    font.pixelSize: 24
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: 'black'
                                }
                            }
                        }
                    }

                    // Boil Status
                    Rectangle {
                        width: parent.width / 3
                        height: parent.height
                        // HLT
                        Column {
                            width: parent.width
                            height: parent.height
                            Rectangle {
                                width: parent.width
                                height: parent.height
                                Label {
                                    text: qsTr('Boil')
                                    font.bold: true
                                    font.pixelSize: 24
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: 'black'
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
