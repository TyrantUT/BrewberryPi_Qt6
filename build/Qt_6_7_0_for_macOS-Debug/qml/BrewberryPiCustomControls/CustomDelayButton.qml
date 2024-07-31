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
          color: Constants.lightColor
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideMiddle
      }

      Rectangle {
          width: Math.min(control.width, control.height) + 2
          height: width
          anchors.centerIn: parent
          radius: width / 2
          color: Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor
          opacity: 0.2
          z: -5
      }

      background: Rectangle {

          opacity: enabled ? 1 : 0.3
          color: control.down ? Constants.warningColor : (control.checked ? Constants.dangerColor : Constants.successColor)


          width: Math.min(control.width, control.height) - 2
          height: width
          radius: width / 2
          anchors.centerIn: parent
          Canvas {
              id: canvas
              anchors.fill: parent
              onPaint: {
                  var ctx = getContext("2d")
                  ctx.clearRect(0, 0, width, height)
                  ctx.strokeStyle = "white"
                  ctx.lineWidth = parent.width / 20
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
