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

    CustomButton {
        id: resetButton

        width: 100
        height: 50
        z: 10
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            left: parent.left
            leftMargin: 5
        }
        text: Constants.isDarkTheme ? "Light" : "Dark"
        backgroundColor: Constants.isDarkTheme ? "#333333" : "#f6f6f6"
        borderColor: Constants.isDarkTheme ? "#ffffff" : "#888888"
        textColor: Constants.isDarkTheme ? "#ffffff" : "#000000"

        onClicked: {
            Constants.isDarkTheme = !Constants.isDarkTheme
        }
    }

    CustomButton {
        id: mashModeButton

        width: 100
        height: 50
        z: 10
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            right: parent.right
            rightMargin: 5
        }
        text: BreweryValues.setpointHltOrMash ? "Mash" : " HLT"
        backgroundColor: Constants.isDarkTheme ? "#333333" : "#f6f6f6"
        borderColor: Constants.isDarkTheme ? "#ffffff" : "#888888"
        textColor: Constants.isDarkTheme ? "#ffffff" : "#000000"

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
