import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import BrewberryPi

pragma ComponentBehavior: Bound

Item {
    id: root

    implicitWidth: 240
    implicitHeight: 300

    signal started()
    signal stopped()
    signal finished()

    property alias selectedHours: hourView.currentIndex
    property alias selectedMinutes: minuteView.currentIndex
    property alias selectedSeconds: secondView.currentIndex
    property bool running: false

    property int remainingTime: (hourView.currentIndex * 3600) +
                                (minuteView.currentIndex * 60) +
                                secondView.currentIndex

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: false

        onTriggered: {
            if (root.remainingTime > 0) {
                root.remainingTime--
                root.updatePickers()
            } else {
                countdownTimer.stop()
                root.running = false
                root.finished()
            }
        }
    }

    function updatePickers() {
        const hrs = Math.floor(root.remainingTime / 3600)
        const mins = Math.floor((root.remainingTime % 3600) / 60)
        const secs = root.remainingTime % 60

        hourView.currentIndex = hrs
        minuteView.currentIndex = mins
        secondView.currentIndex = secs
    }

    Rectangle {
        id: timerContainer
        width: parent.width
        height: parent.height
        radius: 16
        gradient: Gradient {
            GradientStop { position: 0.0; color: Constants.isDarkTheme ? "#1C2526" : "#F5F5F7" }
            GradientStop { position: 1.0; color: Constants.isDarkTheme ? "#2E3B3E" : "#E5E5E7" }
        }
        border.color: Constants.controlBorderColor
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                ListView {
                    id: hourView
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    model: 24
                    orientation: ListView.Vertical
                    snapMode: ListView.SnapToItem
                    boundsBehavior: Flickable.StopAtBounds
                    highlightFollowsCurrentItem: true
                    preferredHighlightBegin: height / 2 - 20
                    preferredHighlightEnd: height / 2 + 20
                    highlightMoveDuration: root.running ? 0 : 250
                    interactive: !root.running

                    onMovementEnded: {
                        let index = Math.round(contentY / 40)
                        currentIndex = Math.max(0, Math.min(index, count - 1))
                    }

                    delegate: Item {
                        required property int modelData
                        width: hourView.width
                        height: 40

                        Item {
                            id: hourTextContainer
                            anchors.centerIn: parent
                            width: hourText.paintedWidth + 4
                            height: hourText.paintedHeight + 4

                            ShaderEffectSource {
                                id: hourTextSource
                                anchors.centerIn: parent
                                width: hourText.paintedWidth
                                height: hourText.paintedHeight
                                sourceItem: hourText
                                hideSource: true
                            }

                            Text {
                                id: hourText
                                text: modelData.toString().padStart(2, "0")
                                font.pixelSize: 24
                                color: hourView.currentIndex === modelData
                                    ? (Constants.isDarkTheme ? "white" : "black")
                                    : (Constants.isDarkTheme ? "gray" : "#888")
                                anchors.centerIn: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }

                            MultiEffect {
                                anchors.fill: hourTextContainer
                                source: hourTextSource
                                shadowEnabled: true
                                shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                                shadowBlur: 2
                                shadowHorizontalOffset: 0
                                shadowVerticalOffset: 0
                                shadowOpacity: 0.6
                                blurEnabled: true
                                blur: 0.1
                                autoPaddingEnabled: true
                            }
                        }
                    }
                }

                Text {
                    id: firstSeparator
                    text: ":"
                    font.pixelSize: 24
                    color: Constants.isDarkTheme ? "white" : "black"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    ShaderEffectSource {
                        id: firstSeparatorSource
                        anchors.centerIn: parent
                        width: firstSeparator.paintedWidth
                        height: firstSeparator.paintedHeight
                        sourceItem: firstSeparator
                        hideSource: true
                    }

                    MultiEffect {
                        anchors.fill: firstSeparator
                        source: firstSeparatorSource
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                        shadowBlur: 2
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0
                        shadowOpacity: 0.6
                        blurEnabled: true
                        blur: 0.1
                        autoPaddingEnabled: true
                    }
                }

                ListView {
                    id: minuteView
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    model: 60
                    orientation: ListView.Vertical
                    snapMode: ListView.SnapToItem
                    boundsBehavior: Flickable.StopAtBounds
                    highlightFollowsCurrentItem: true
                    preferredHighlightBegin: height / 2 - 20
                    preferredHighlightEnd: height / 2 + 20
                    highlightMoveDuration: root.running ? 0 : 250
                    interactive: !root.running

                    onMovementEnded: {
                        let index = Math.round(contentY / 40)
                        currentIndex = Math.max(0, Math.min(index, count - 1))
                    }

                    delegate: Item {
                        required property int modelData
                        width: minuteView.width
                        height: 40

                        Item {
                            id: minuteTextContainer
                            anchors.centerIn: parent
                            width: minuteText.paintedWidth + 4
                            height: minuteText.paintedHeight + 4

                            ShaderEffectSource {
                                id: minuteTextSource
                                anchors.centerIn: parent
                                width: minuteText.paintedWidth
                                height: minuteText.paintedHeight
                                sourceItem: minuteText
                                hideSource: true
                            }

                            Text {
                                id: minuteText
                                text: modelData.toString().padStart(2, "0")
                                font.pixelSize: 24
                                color: minuteView.currentIndex === modelData
                                    ? (Constants.isDarkTheme ? "white" : "black")
                                    : (Constants.isDarkTheme ? "gray" : "#888")
                                anchors.centerIn: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }

                            MultiEffect {
                                anchors.fill: minuteTextContainer
                                source: minuteTextSource
                                shadowEnabled: true
                                shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                                shadowBlur: 2
                                shadowHorizontalOffset: 0
                                shadowVerticalOffset: 0
                                shadowOpacity: 0.6
                                blurEnabled: true
                                blur: 0.1
                                autoPaddingEnabled: true
                            }
                        }
                    }
                }

                Text {
                    id: secondSeparator
                    text: ":"
                    font.pixelSize: 24
                    color: Constants.isDarkTheme ? "white" : "black"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    ShaderEffectSource {
                        id: secondSeparatorSource
                        anchors.centerIn: parent
                        width: secondSeparator.paintedWidth
                        height: secondSeparator.paintedHeight
                        sourceItem: secondSeparator
                        hideSource: true
                    }

                    MultiEffect {
                        anchors.fill: secondSeparator
                        source: secondSeparatorSource
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                        shadowBlur: 2
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0
                        shadowOpacity: 0.6
                        blurEnabled: true
                        blur: 0.1
                        autoPaddingEnabled: true
                    }
                }

                ListView {
                    id: secondView
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    model: 60
                    orientation: ListView.Vertical
                    snapMode: ListView.SnapToItem
                    boundsBehavior: Flickable.StopAtBounds
                    highlightFollowsCurrentItem: true
                    preferredHighlightBegin: height / 2 - 20
                    preferredHighlightEnd: height / 2 + 20
                    highlightMoveDuration: root.running ? 0 : 250
                    interactive: !root.running

                    onMovementEnded: {
                        let index = Math.round(contentY / 40)
                        currentIndex = Math.max(0, Math.min(index, count - 1))
                    }

                    delegate: Item {
                        required property int modelData
                        width: secondView.width
                        height: 40

                        Item {
                            id: secondTextContainer
                            anchors.centerIn: parent
                            width: secondText.paintedWidth + 4
                            height: secondText.paintedHeight + 4

                            ShaderEffectSource {
                                id: secondTextSource
                                anchors.centerIn: parent
                                width: secondText.paintedWidth
                                height: secondText.paintedHeight
                                sourceItem: secondText
                                hideSource: true
                            }

                            Text {
                                id: secondText
                                text: modelData.toString().padStart(2, "0")
                                font.pixelSize: 24
                                color: secondView.currentIndex === modelData
                                    ? (Constants.isDarkTheme ? "white" : "black")
                                    : (Constants.isDarkTheme ? "gray" : "#888")
                                anchors.centerIn: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }

                            MultiEffect {
                                anchors.fill: secondTextContainer
                                source: secondTextSource
                                shadowEnabled: true
                                shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                                shadowBlur: 2
                                shadowHorizontalOffset: 0
                                shadowVerticalOffset: 0
                                shadowOpacity: 0.6
                                blurEnabled: true
                                blur: 0.1
                                autoPaddingEnabled: true
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Button {
                    id: startStopButton
                    text: root.running ? "Stop" : "Start"
                    onClicked: {
                        scaleAnimation.start()
                        if (!root.running) {
                            root.remainingTime = (hourView.currentIndex * 3600) +
                                                 (minuteView.currentIndex * 60) +
                                                 secondView.currentIndex
                            if (root.remainingTime > 0) {
                                countdownTimer.start()
                                root.running = true
                                root.started()
                            }
                        } else {
                            countdownTimer.stop()
                            root.running = false
                            root.stopped()
                        }
                    }
                    font.pixelSize: 18

                    Rectangle {
                        width: parent.width + 2
                        height: parent.height + 2
                        radius: height / 2
                        color: Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor
                        opacity: 0.1
                        anchors.centerIn: parent
                    }

                    background: Rectangle {
                        id: startBackground
                        color: root.running
                            ? (Constants.isDarkTheme ? "#cc3333" : "#ff4444")
                            : (Constants.isDarkTheme ? "#33aa33" : "#33cc33")
                        border.color: Constants.isDarkTheme ? Constants.backgroundColor : Qt.darker(Constants.backgroundColor, 1.6)
                        radius: 12

                        Rectangle {
                            width: parent.width - 4
                            height: parent.height - 4
                            anchors.centerIn: parent
                            color: 'transparent'
                            border.color: Constants.darkColor
                            border.width: 2
                            opacity: .2
                            radius: parent.radius
                            visible: startStopButton.down
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: 18
                    }

                    SequentialAnimation {
                        id: scaleAnimation
                        PropertyAnimation { target: startStopButton; property: "scale"; to: 0.95; duration: 50 }
                        PropertyAnimation { target: startStopButton; property: "scale"; to: 1.0; duration: 50 }
                    }
                }

                Button {
                    id: resetButton
                    text: "Reset"
                    enabled: !root.running
                    onClicked: {
                        resetScaleAnimation.start()
                        countdownTimer.stop()
                        root.remainingTime = 0
                        hourView.currentIndex = 0
                        minuteView.currentIndex = 0
                        secondView.currentIndex = 0
                    }
                    font.pixelSize: 18

                    Rectangle {
                        width: parent.width + 2
                        height: parent.height + 2
                        radius: height / 2
                        color: Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor
                        opacity: 0.1
                        anchors.centerIn: parent
                    }

                    background: Rectangle {
                        id: resetBackground
                        color: Constants.isDarkTheme ? "#888888" : "#dddddd"
                        radius: 12
                        border.color: Constants.isDarkTheme ? Constants.backgroundColor : Qt.darker(Constants.backgroundColor, 1.6)
                        border.width: 1

                        Rectangle {
                            width: parent.width - 4
                            height: parent.height - 4
                            anchors.centerIn: parent
                            color: 'transparent'
                            border.color: Constants.darkColor
                            border.width: 2
                            opacity: .2
                            radius: parent.radius
                            visible: resetButton.down
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        anchors.centerIn: parent
                        color: Constants.isDarkTheme ? "white" : "black"
                        font.pixelSize: 18
                    }

                    SequentialAnimation {
                        id: resetScaleAnimation
                        PropertyAnimation { target: resetButton; property: "scale"; to: 0.95; duration: 50 }
                        PropertyAnimation { target: resetButton; property: "scale"; to: 1.0; duration: 50 }
                    }
                }
            }
        }
    }
}
