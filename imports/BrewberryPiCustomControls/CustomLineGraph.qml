import QtQuick

Item {
    id: root

    // Public properties
    property real maxTemperature: 215 // Maximum temperature for scaling
    property real timeWindow: 30 // Visible time window in seconds
    property int maxPoints: 100 // Number of points for smooth rendering
    property alias running: timer.running // Control whether the graph is updating
    property real currentTemperature: 0 // Bindable property for external temperature
    property real bufferTime: 0.5 // Seconds to place new points beyond visible window

    // Canvas for drawing the graph
    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            if (internal.temperatures.length < 1) {
                return // No points to draw
            }

            var currentTime = Date.now() / 1000 // Current time in seconds
            var visibleTimeSpan = root.timeWindow
            var yScale = height / root.maxTemperature
            var xScale = width / visibleTimeSpan

            ctx.lineWidth = 2
            ctx.beginPath()

            // Start at the first valid point within the extended time window
            var extendedTimeSpan = visibleTimeSpan + root.bufferTime
            var firstValidIndex = 0
            for (var i = 0; i < internal.temperatures.length; i++) {
                if (internal.timestamps[i] >= currentTime - extendedTimeSpan) {
                    firstValidIndex = i
                    break
                }
            }

            // Move to the first point
            var x0 = (internal.timestamps[firstValidIndex] - (currentTime - visibleTimeSpan)) * xScale
            var y0 = height - internal.temperatures[firstValidIndex] * yScale
            ctx.moveTo(x0, y0)

            // Draw straight lines for 1-2 points, quadratic curves for 3+ points
            if (internal.temperatures.length == 1) {
                // Single point: draw a dot
                ctx.arc(x0, y0, 2, 0, 2 * Math.PI)
                ctx.fillStyle = Qt.rgba(internal.temperatures[firstValidIndex] / root.maxTemperature, 0, 1 - internal.temperatures[firstValidIndex] / root.maxTemperature, 1)
                ctx.fill()
            } else if (internal.temperatures.length == 2) {
                // Two points: draw a straight line
                var x1 = (internal.timestamps[firstValidIndex + 1] - (currentTime - visibleTimeSpan)) * xScale
                var y1 = height - internal.temperatures[firstValidIndex + 1] * yScale
                ctx.lineTo(x1, y1)
                ctx.strokeStyle = Qt.rgba(internal.temperatures[firstValidIndex] / root.maxTemperature, 0, 1 - internal.temperatures[firstValidIndex] / root.maxTemperature, 1)
                ctx.stroke()
            } else {
                // Three or more points: draw quadratic curves
                for (i = firstValidIndex; i < internal.temperatures.length - 1; i++) {
                    var t0 = internal.timestamps[i]
                    var t1 = internal.timestamps[i + 1]

                    // Skip points outside the extended time window
                    if (t0 < currentTime - extendedTimeSpan) continue

                    x0 = (t0 - (currentTime - visibleTimeSpan)) * xScale
                    var x1 = (t1 - (currentTime - visibleTimeSpan)) * xScale
                    y0 = height - internal.temperatures[i] * yScale
                    var y1 = height - internal.temperatures[i + 1] * yScale

                    // Control point at midpoint for smooth curve
                    var xc = (x0 + x1) / 2
                    var yc = (y0 + y1) / 2

                    ctx.quadraticCurveTo(x0, y0, xc, yc)

                    // Color based on starting point's temperature
                    ctx.strokeStyle = Qt.rgba(internal.temperatures[i] / root.maxTemperature, 0, 1 - internal.temperatures[i] / root.maxTemperature, 1)
                }

                // Connect to the last point
                if (i == internal.temperatures.length - 1) {
                    var lastX = (internal.timestamps[i] - (currentTime - visibleTimeSpan)) * xScale
                    var lastY = height - internal.temperatures[i] * yScale
                    ctx.quadraticCurveTo(xc, yc, lastX, lastY)
                }

                ctx.stroke()
            }
        }

        // Smooth animation for scrolling
        Behavior on x {
            NumberAnimation { duration: 1000 / 60 } // 60 FPS
        }
    }

    // Timer for continuous updates and point addition
    Timer {
        id: timer
        interval: 500 // Match Main.qml's update rate
        running: true
        repeat: true
        onTriggered: {
            var currentTime = Date.now() / 1000
            var futureTime = currentTime + root.bufferTime // Add points beyond visible window

            // Maintain maxPoints limit
            if (internal.rawTemperatures.length >= root.maxPoints) {
                internal.rawTemperatures.shift()
                internal.temperatures.shift()
                internal.timestamps.shift()
            }

            // Add new point even if temperature hasn't changed
            internal.rawTemperatures.push(currentTemperature)
            internal.timestamps.push(futureTime)

            // Apply moving average (window of 3 points) on interpolated temperature
            if (internal.rawTemperatures.length >= 3) {
                var avgTemp = (
                    internal.temperatures[internal.temperatures.length - 2] * 0.2 +
                    internal.temperatures[internal.temperatures.length - 1] * 0.3 +
                    smoothedTemperature * 0.5
                )
                internal.temperatures.push(avgTemp)
            } else {
                internal.temperatures.push(smoothedTemperature)
            }

            // Request repaint to update scrolling
            canvas.requestPaint()

            // Clean up old data outside extended time window
            var extendedTimeSpan = root.timeWindow + root.bufferTime
            while (internal.timestamps.length > 0 && internal.timestamps[0] < currentTime - extendedTimeSpan) {
                internal.timestamps.shift()
                internal.temperatures.shift()
                internal.rawTemperatures.shift()
            }
        }
    }

    // Internal data storage
    QtObject {
        id: internal
        property var timestamps: [] // Store timestamps
        property var temperatures: [] // Store smoothed temperature values
        property var rawTemperatures: [] // Store raw input temperatures
        property real lastRawTemp: 0 // Last raw temperature for interpolation
        property real interpolatedTemp: 0 // Current interpolated temperature
    }

    // Smooth temperature transitions with NumberAnimation
    property real smoothedTemperature: 0
    NumberAnimation on smoothedTemperature {
        id: tempAnimation
        duration: 500 // Interpolate over 500ms
        easing.type: Easing.InOutQuad // Smooth easing for natural transitions
    }

    // Handle temperature changes with smoothing
    onCurrentTemperatureChanged: {
        // Update interpolated temperature
        internal.lastRawTemp = internal.rawTemperatures.length > 0 ? internal.rawTemperatures[internal.rawTemperatures.length - 1] : currentTemperature
        tempAnimation.to = currentTemperature
        tempAnimation.start()
    }

    // Update displayed temperature based on animation
    onSmoothedTemperatureChanged: {
        if (internal.temperatures.length > 0) {
            internal.temperatures[internal.temperatures.length - 1] = smoothedTemperature
            canvas.requestPaint()
        }
    }
}
