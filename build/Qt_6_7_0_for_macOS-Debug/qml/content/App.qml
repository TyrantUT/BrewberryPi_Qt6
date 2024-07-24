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

    SwipeView {
        id: mainSwipeView
        anchors.fill: parent

        SwipeViewPage1 {}
        SwipeViewPage2 {}
    }
}
