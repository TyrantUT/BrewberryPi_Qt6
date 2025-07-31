// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick
import QtQuick.Controls
import BrewberryPi
import BrewberryPiCustomControls

ApplicationWindow {
    title: "BrewberryPi"
    width: Constants.width
    height: Constants.height
    visible: true

    Button {
        id: displayModeButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            left: parent.left
            leftMargin: 5
        }
        width: 100
        height: 50
        z: 10
        text: Constants.isDarkTheme ? "Light" : "Dark"

        contentItem: Text {
            text: displayModeButton.text
            font.pixelSize: height / 2
            font.bold: true
            color: Constants.isDarkTheme ? "#ffffff" : "#000000"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: {
            Constants.isDarkTheme = !Constants.isDarkTheme
        }

        background: Rectangle {
            implicitWidth: displayModeButton.width
            implicitHeight: displayModeButton.height
            color: Constants.isDarkTheme ? "#333333" : "#f6f6f6"
            border.color: Constants.isDarkTheme ? "#ffffff" : "#888888"
            border.width: 1
            radius: 8
        }
    }

    Button {
        id: mashModeButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            right: parent.right
            rightMargin: 5
        }
        width: 100
        height: 50
        text: BreweryValues.setpointHltOrMash ? "Mash" : " HLT"
        z: 10

        contentItem: Text {
            text: mashModeButton.text
            font.pixelSize: height / 2
            font.bold: true
            color: Constants.isDarkTheme ? "#ffffff" : "#000000"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            implicitWidth: mashModeButton.width
            implicitHeight: mashModeButton.height
            color: Constants.isDarkTheme ? "#333333" : "#f6f6f6"
            border.color: Constants.isDarkTheme ? "#ffffff" : "#888888"
            border.width: 1
            radius: 8
        }

        onClicked: {
            BreweryValues.setpointHltOrMash = !BreweryValues.setpointHltOrMash
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
