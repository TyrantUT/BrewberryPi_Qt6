import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Page {
    id: page

    MouseArea {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 50
        height: 50
        onDoubleClicked: {
            Constants.isDarkTheme = !Constants.isDarkTheme
        }
    }

    // Main container
    Column {
        anchors.fill: parent

        Page1MainTop {
            width: parent.width
            height: parent.height * 2/3
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "black"
        }

        Page1MainBottom {
            width: parent.width
            height: parent.height * 1/3
        }
    }
}
