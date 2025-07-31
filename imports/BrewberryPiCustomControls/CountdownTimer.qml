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

                        Row {
                            id: hourTextContainer
                            anchors.centerIn: parent
                            spacing: 2

                            Item {
                                width: hourTextLeft.paintedWidth + 4
                                height: hourTextLeft.paintedHeight + 4

                                ShaderEffectSource {
                                    id: hourTextSourceLeft
                                    anchors.centerIn: parent
                                    width: hourTextLeft.paintedWidth
                                    height: hourTextLeft.paintedHeight
                                    sourceItem: hourTextLeft
                                    hideSource: true
                                }

                                Text {
                                    id: hourTextLeft
                                    text: Math.floor(modelData / 10).toString()
                                    font.pixelSize: 24
                                    color: hourView.currentIndex === modelData
                                        ? (Constants.isDarkTheme ? "white" : "black")
                                        : (Constants.isDarkTheme ? "gray" : "#888")
                                    anchors.centerIn: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                MultiEffect {
                                    anchors.fill: parent
                                    source: hourTextSourceLeft
                                    shadowEnabled: true
                                    shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                                    shadowBlur: 3
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 0
                                    shadowOpacity: 0.5
                                    blurEnabled: true
                                    blur: 0.15
                                    autoPaddingEnabled: true
                                }
                            }

                            Item {
                                width: hourTextRight.paintedWidth + 4
                                height: hourTextRight.paintedHeight + 4

                                ShaderEffectSource {
                                    id: hourTextSourceRight
                                    anchors.centerIn: parent
                                    width: hourTextRight.paintedWidth
                                    height: hourTextRight.paintedHeight
                                    sourceItem: hourTextRight
                                    hideSource: true
                                }

                                Text {
                                    id: hourTextRight
                                    text: (modelData % 10).toString()
                                    font.pixelSize: 24
                                    color: hourView.currentIndex === modelData
                                        ? (Constants.isDarkTheme ? "white" : "black")
                                        : (Constants.isDarkTheme ? "gray" : "#888")
                                    anchors.centerIn: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                MultiEffect {
                                    anchors.fill: parent
                                    source: hourTextSourceRight
                                    shadowEnabled: true
                                    shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                                    shadowBlur: 3
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 0
                                    shadowOpacity: 0.5
                                    blurEnabled: true
                                    blur: 0.15
                                    autoPaddingEnabled: true
                                }
                            }
                        }
                    }
                }

                Item {
                    id: firstSeparatorContainer
                    width: firstSeparator.paintedWidth + 4
                    height: firstSeparator.paintedHeight + 4
                    Layout.alignment: Qt.AlignVCenter

                    ShaderEffectSource {
                        id: firstSeparatorSource
                        anchors.centerIn: parent
                        width: firstSeparator.paintedWidth
                        height: firstSeparator.paintedHeight
                        sourceItem: firstSeparator
                        hideSource: true
                    }

                    Text {
                        id: firstSeparator
                        text: ":"
                        font.pixelSize: 24
                        color: Constants.isDarkTheme ? "white" : "black"
                        anchors.centerIn: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MultiEffect {
                        anchors.fill: firstSeparatorContainer
                        source: firstSeparatorSource
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                        shadowBlur: 3
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0
                        shadowOpacity: 0.5
                        blurEnabled: true
                        blur: 0.15
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

                        Row {
                            id: minuteTextContainer
                            anchors.centerIn: parent
                            spacing: 2

                            Item {
                                width: minuteTextLeft.paintedWidth + 4
                                height: minuteTextLeft.paintedHeight + 4

                                ShaderEffectSource {
                                    id: minuteTextSourceLeft
                                    anchors.centerIn: parent
                                    width: minuteTextLeft.paintedWidth
                                    height: minuteTextLeft.paintedHeight
                                    sourceItem: minuteTextLeft
                                    hideSource: true
                                }

                                Text {
                                    id: minuteTextLeft
                                    text: Math.floor(modelData / 10).toString()
                                    font.pixelSize: 24
                                    color: minuteView.currentIndex === modelData
                                        ? (Constants.isDarkTheme ? "white" : "black")
                                        : (Constants.isDarkTheme ? "gray" : "#888")
                                    anchors.centerIn: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                MultiEffect {
                                    anchors.fill: parent
                                    source: minuteTextSourceLeft
                                    shadowEnabled: true
                                    shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                                    shadowBlur: 3
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 0
                                    shadowOpacity: 0.5
                                    blurEnabled: true
                                    blur: 0.15
                                    autoPaddingEnabled: true
                                }
                            }

                            Item {
                                width: minuteTextRight.paintedWidth + 4
                                height: minuteTextRight.paintedHeight + 4

                                ShaderEffectSource {
                                    id: minuteTextSourceRight
                                    anchors.centerIn: parent
                                    width: minuteTextRight.paintedWidth
                                    height: minuteTextRight.paintedHeight
                                    sourceItem: minuteTextRight
                                    hideSource: true
                                }

                                Text {
                                    id: minuteTextRight
                                    text: (modelData % 10).toString()
                                    font.pixelSize: 24
                                    color: minuteView.currentIndex === modelData
                                        ? (Constants.isDarkTheme ? "white" : "black")
                                        : (Constants.isDarkTheme ? "gray" : "#888")
                                    anchors.centerIn: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                MultiEffect {
                                    anchors.fill: parent
                                    source: minuteTextSourceRight
                                    shadowEnabled: true
                                    shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                                    shadowBlur: 3
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 0
                                    shadowOpacity: 0.5
                                    blurEnabled: true
                                    blur: 0.15
                                    autoPaddingEnabled: true
                                }
                            }
                        }
                    }
                }

                Item {
                    id: secondSeparatorContainer
                    width: secondSeparator.paintedWidth + 4
                    height: secondSeparator.paintedHeight + 4
                    Layout.alignment: Qt.AlignVCenter

                    ShaderEffectSource {
                        id: secondSeparatorSource
                        anchors.centerIn: parent
                        width: secondSeparator.paintedWidth
                        height: secondSeparator.paintedHeight
                        sourceItem: secondSeparator
                        hideSource: true
                    }

                    Text {
                        id: secondSeparator
                        text: ":"
                        font.pixelSize: 24
                        color: Constants.isDarkTheme ? "white" : "black"
                        anchors.centerIn: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MultiEffect {
                        anchors.fill: secondSeparatorContainer
                        source: secondSeparatorSource
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                        shadowBlur: 3
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0
                        shadowOpacity: 0.5
                        blurEnabled: true
                        blur: 0.15
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

                        Row {
                            id: secondTextContainer
                            anchors.centerIn: parent
                            spacing: 2

                            Item {
                                width: secondTextLeft.paintedWidth + 4
                                height: secondTextLeft.paintedHeight + 4

                                ShaderEffectSource {
                                    id: secondTextSourceLeft
                                    anchors.centerIn: parent
                                    width: secondTextLeft.paintedWidth
                                    height: secondTextLeft.paintedHeight
                                    sourceItem: secondTextLeft
                                    hideSource: true
                                }

                                Text {
                                    id: secondTextLeft
                                    text: Math.floor(modelData / 10).toString()
                                    font.pixelSize: 24
                                    color: secondView.currentIndex === modelData
                                        ? (Constants.isDarkTheme ? "white" : "black")
                                        : (Constants.isDarkTheme ? "gray" : "#888")
                                    anchors.centerIn: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                MultiEffect {
                                    anchors.fill: parent
                                    source: secondTextSourceLeft
                                    shadowEnabled: true
                                    shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                                    shadowBlur: 3
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 0
                                    shadowOpacity: 0.5
                                    blurEnabled: true
                                    blur: 0.15
                                    autoPaddingEnabled: true
                                }
                            }

                            Item {
                                width: secondTextRight.paintedWidth + 4
                                height: secondTextRight.paintedHeight + 4

                                ShaderEffectSource {
                                    id: secondTextSourceRight
                                    anchors.centerIn: parent
                                    width: secondTextRight.paintedWidth
                                    height: secondTextRight.paintedHeight
                                    sourceItem: secondTextRight
                                    hideSource: true
                                }

                                Text {
                                    id: secondTextRight
                                    text: (modelData % 10).toString()
                                    font.pixelSize: 24
                                    color: secondView.currentIndex === modelData
                                        ? (Constants.isDarkTheme ? "white" : "black")
                                        : (Constants.isDarkTheme ? "gray" : "#888")
                                    anchors.centerIn: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                MultiEffect {
                                    anchors.fill: parent
                                    source: secondTextSourceRight
                                    shadowEnabled: true
                                    shadowColor: Qt.rgba(0.8, 0.8, 0.8, 0.4)
                                    shadowBlur: 3
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 0
                                    shadowOpacity: 0.5
                                    blurEnabled: true
                                    blur: 0.15
                                    autoPaddingEnabled: true
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                CustomButton {
                    id: startStopButton
                    text: root.running ? "Stop" : "Start"
                    backgroundColor: root.running
                        ? (Constants.isDarkTheme ? "#cc3333" : "#ff4444")
                        : (Constants.isDarkTheme ? "#33aa33" : "#33cc33")
                    textColor: "white"
                    onClicked: {
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
                }

                CustomButton {
                    id: resetButton
                    text: "Reset"
                    enabled: !root.running
                    backgroundColor: Constants.isDarkTheme ? "#888888" : "#dddddd"
                    textColor: Constants.isDarkTheme ? "white" : "black"
                    onClicked: {
                        countdownTimer.stop()
                        root.remainingTime = 0
                        hourView.currentIndex = 0
                        minuteView.currentIndex = 0
                        secondView.currentIndex = 0
                    }
                }
            }
        }
    }
}
