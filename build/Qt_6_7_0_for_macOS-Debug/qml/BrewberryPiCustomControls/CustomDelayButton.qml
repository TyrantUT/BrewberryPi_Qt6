import QtQuick
import BrewberryPi
import QtQuick.Controls as T

T.DelayButton {
      id: control
      delay: 2000
      font.pointSize: 22
      text: qsTr("Off")

      onProgressChanged: {
          canvas.requestPaint()
      }

      contentItem: Text {
          text: control.text
          font: control.font
          opacity: enabled ? 1.0 : 0.3
          color: "white"
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideMiddle
      }

      background: Rectangle {

          readonly property real size: Math.min(control.width, control.height)
          opacity: enabled ? 1 : 0.3
          color: control.down ? "#17a81a" : (control.checked ? "#f4362b" : "#21be2b")
          radius: size / 2

          width: size
          height: size
          anchors.centerIn: parent

          Canvas {
              id: canvas
              anchors.fill: parent
              onPaint: {
                  var ctx = getContext("2d")
                  ctx.clearRect(0, 0, width, height)
                  ctx.strokeStyle = "white"
                  ctx.lineWidth = parent.size / 20
                  ctx.beginPath()
                  var startAngle = Math.PI / 5 * 3
                  var endAngle = startAngle + control.progress * Math.PI / 5 * 9
                  ctx.arc(width / 2, height / 2, width / 2 - ctx.lineWidth / 2 - 2, startAngle, endAngle)
                  ctx.stroke()
              }
          }
      }

      onCheckedChanged:  {
          if (checked) {
              text = qsTr("On");
          }
          else {
              text = qsTr("Off");
          }
      }
}
