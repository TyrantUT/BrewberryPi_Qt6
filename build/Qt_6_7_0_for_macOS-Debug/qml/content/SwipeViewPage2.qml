import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    TabBar {
        id: mainTabBar
        width: parent.width
        contentHeight: 50

        TabButton {
            text: qsTr("HLT")
            font.bold: true
            font.pixelSize: 24
        }
        TabButton {
            text: qsTr("Mash")
            font.bold: true
            font.pixelSize: 24
        }

        TabButton {
            text: qsTr("Boil")
            font.bold: true
            font.pixelSize: 24
        }
    }

    StackLayout {
        width: parent.width
        height: parent.height - mainTabBar.height
        currentIndex: mainTabBar.currentIndex
        anchors {
            top: mainTabBar.bottom
        }

        StackLayoutHlt {}
        StackLayoutMash {}
        StackLayoutBoil {}
    }
}
