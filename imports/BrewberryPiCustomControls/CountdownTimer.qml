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

    // Outer shadow effect around the whole widget
    Rectangle {
        id: timerContainer
        width: parent.width
        height: parent.height
        radius: 12
        color: Constants.backgroundColor
        border.color: Constants.controlBorderColor
        border.width: 1

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Constants.controlShadowColor
            shadowVerticalOffset: 0
            shadowHorizontalOffset: 4
            shadowBlur: 12
        }

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

                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: 24
                            color: hourView.currentIndex === modelData
                                ? (Constants.isDarkTheme ? "white" : "black")
                                : (Constants.isDarkTheme ? "gray" : "#888")
                            text: modelData.toString().padStart(2, "0")
                        }
                    }
                }

                Text {
                    text: ":"
                    font.pixelSize: 24
                    color: Constants.isDarkTheme ? "white" : "black"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
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

                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: 24
                            color: minuteView.currentIndex === modelData
                                ? (Constants.isDarkTheme ? "white" : "black")
                                : (Constants.isDarkTheme ? "gray" : "#888")
                            text: modelData.toString().padStart(2, "0")
                        }
                    }
                }

                Text {
                    text: ":"
                    font.pixelSize: 24
                    color: Constants.isDarkTheme ? "white" : "black"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
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

                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: 24
                            color: secondView.currentIndex === modelData
                                ? (Constants.isDarkTheme ? "white" : "black")
                                : (Constants.isDarkTheme ? "gray" : "#888")
                            text: modelData.toString().padStart(2, "0")
                        }
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                // Styled Start/Stop Button
                Button {
                    id: startStopButton
                    text: root.running ? "Stop" : "Start"
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
                        border.color: Constants.isDarkTheme ? Constants.backgroundColor : !Constants.backgroundColor
                        radius: 12
                        layer.enabled: true

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
                }

                // Styled Reset Button
                Button {
                    id: resetButton
                    text: "Reset"
                    enabled: !root.running
                    onClicked: {
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
                        border.color: Constants.isDarkTheme ? Constants.backgroundColor : !Constants.backgroundColor
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
                }
            }
        }
    }
}
