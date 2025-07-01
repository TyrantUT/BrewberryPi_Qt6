import QtQuick
import QtQuick.Controls.Basic
import BrewberryPi

pragma ComponentBehavior: Bound

DelayButton {
      id: control
      delay: 2000
      font.bold: true
      font.pointSize: 22
      text: qsTr("Off")

      onProgressChanged: {
          canvas.requestPaint();
      }

      contentItem: Text {
          text: control.text
          font: control.font
          opacity: enabled ? 1.0 : 0.3
          color: Constants.lightColor
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
      }

      Rectangle {
          width: Math.min(control.width, control.height) + 2
          height: width
          anchors.centerIn: parent
          radius: width / 2
          color: Constants.backgroundColor
          opacity: 0.1
      }

      background: Rectangle {
          opacity: enabled ? 1 : 0.3
          color: control.down ? Constants.warningColor : (control.checked ? Constants.dangerColor : Constants.successColor)
          width: Math.min(control.width, control.height) - 2
          height: width
          radius: width / 2
          anchors.centerIn: parent

          // Shadow effect using multiple rectangles
          Rectangle {
              property color darkBorder: (Constants.isDarkTheme ? Constants.lightColor : Constants.darkColor)
              property color lightBorder: (Constants.isDarkTheme ? Constants.darkColor : Constants.lightColor)
              width: parent.width - 2
              height: parent.height - 2
              radius: height / 2
              opacity: 0.4
              anchors.centerIn: parent
              color: 'transparent'
              border.color: control.checked ? darkBorder : lightBorder
              border.width: 2
          }

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
