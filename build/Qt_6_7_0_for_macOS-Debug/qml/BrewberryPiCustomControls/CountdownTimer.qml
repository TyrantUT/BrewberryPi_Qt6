import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import BrewberryPi

Item {
    Rectangle {
        color: 'blue'
        width: 200
        height: 200

        property double startTime: 0

        ColumnLayout {
            anchors.fill: parent

            Text {
                id: time
                font.pixelSize: 30
                color: 'black'
                text: "--"
                Layout.alignment: Qt.AlignCenter
            }

            Button {
                text: "Click me!"
                Layout.alignment: Qt.AlignCenter

                onClicked: {
                    if(startTime == 0){
                        time.text = "click again..."
                        startTime = new Date().getTime()
                    } else {
                        time.text = new Date().getTime() - startTime + " ms"
                        startTime = 0
                    }
                }
            }
        }
    }
}

