// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick
import QtQuick.Controls
import BrewberryPi

ApplicationWindow {
    title: "BrewberryPi"
    width: Constants.width
    height: Constants.height
    visible: true

    Button {
        id: control
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        width: 100
        height: 50
        z: 10
        text: Constants.isDarkTheme ? "Light Mode" : "Dark Mode"

        contentItem: Text {
            text: control.text
            font: control.font
            color: Constants.isDarkTheme ? "#ffffff" : "#000000"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: {
            Constants.isDarkTheme = !Constants.isDarkTheme
        }

        background: Rectangle {
            implicitWidth: control.width
            implicitHeight: control.height
            color: Constants.isDarkTheme ? "#333333" : "#f6f6f6"
            border.color: Constants.isDarkTheme ? "#ffffff" : "#888888"
            border.width: 1
            radius: 8
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
            color: 'black'
        }

        Page1MainBottom {
            width: parent.width
            height: parent.height * 1/3
        }
    }
}
