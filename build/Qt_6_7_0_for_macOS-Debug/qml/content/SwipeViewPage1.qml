import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

Page {
    id: page

    // Main container
    Column {
        anchors.fill: parent

        Page1MainTop {
            width: parent.width
            height: parent.height * 2/3
        }

        Page1MainBottom {
            width: parent.width
            height: parent.height * 1/3
        }
    }
}
