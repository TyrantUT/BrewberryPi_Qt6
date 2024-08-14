import QtQuick
import QtQuick.Shapes

pragma ComponentBehavior: Bound

Shape {
    id: control
    containsMode: Shape.FillContains

    property int outerStrokeArea: 0
    signal clicked()

    TapHandler {
        onTapped: control.clicked()
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
            startAngle: 0
            sweepAngle: 360
        }
    }
}
