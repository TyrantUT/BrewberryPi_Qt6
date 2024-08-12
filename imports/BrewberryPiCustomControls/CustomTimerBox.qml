import QtQuick
import BrewberryPi
import "../BrewberryPi/BreweryFunctions.js" as BreweryFunctions

pragma ComponentBehavior: Bound

Text {
    text: BreweryFunctions.getIntToTime(BreweryValues.breweryTimer)
    color: (!BreweryValues.breweryTimerRunning && BreweryValues.breweryTimer === 0) ? Constants.dangerColor : (Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor)
    font.pixelSize: parent.height
    elide: Qt.ElideMiddle
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    anchors.horizontalCenter: parent.horizontalCenter

    Rectangle {
        width: parent.width - 4
        height: 2
        color: 'lightblue'
        anchors.bottom: parent.bottom
    }
}
