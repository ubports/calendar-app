import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Themes.Ambiance 0.1
Item
{
   property alias header: header.text
   property alias value: value.text
   property string headerColor :"black"
   property string detailColor :"grey"
   property int xMargin
   property int headerWidth: header.width
   width: parent.width
   height: header.height
   Label{
      id: header
      color: headerColor
      font.bold: true
      fontSize: "medium"
      anchors.left: parent.left
   }
   Label{
        id:value
        x: xMargin + units.gu(1)
        color: detailColor
        fontSize: "medium"
   }
}
