import QtQuick
import QtQuick.Shapes

Shape {
    id: control

    property int outerStrokeArea: 0
    property bool flip: false

    signal doubleClicked()

    containsMode: Shape.FillContains

    TapHandler {
        onDoubleTapped: control.doubleClicked()
    }

    ShapePath {
        fillColor: 'transparent'
        strokeColor: 'transparent'
        strokeWidth: 0

        PathAngleArc {
            centerX: control.width / 2
            centerY: centerX
            radiusX: (control.width / 2) - outerStrokeArea
            radiusY: radiusX
            startAngle: flip ? 0 : -180
            sweepAngle: 180
        }
    }
}
