import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Dialog {
    id: root
    title: i18n.tr("Select Color")
    height: units.gu(100)

    signal accepted(var color)
    signal rejected()

    contents: [
        Grid{
            height: units.gu(25)
            rows: 3
            columns: 5
            Repeater{
                model: ["#2C001E","#333333","#DD4814","#DF382C","#EFB73E","#19B6EE","#38B44A","#001F5C"];
                delegate:UbuntuShape{
                    width: (parent.width/5)
                    height: width
                    color: modelData

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            root.accepted(modelData)
                            PopupUtils.close(root)
                        }
                    }
                }
            }
        },
        Button {
            objectName: "TimePickerCancelButton"
            text: i18n.tr("Cancel")
            onClicked: {
                root.rejected()
                PopupUtils.close(root)
            }
            width: (parent.width) / 2
        }
    ]
}
