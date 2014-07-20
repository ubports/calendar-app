import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import QtOrganizer 5.0

Page {
    id: root
    title: i18n.tr("Calendars")

    property var model;

    signal collectionUpdated();

    ToolbarItems {
        id: pickerModeToolbar

        back: ToolbarButton {
            action: Action {
                text: i18n.tr("Back");
                iconName: "back"
                onTriggered: {
                    pageStack.pop();
                }
            }
        }

        ToolbarButton {
            action: Action {
                text: i18n.tr("Save");
                iconSource: Qt.resolvedUrl("save.svg");
                onTriggered: {
                    root.collectionUpdated();
                    pageStack.pop();
                }
            }
        }
    }

    tools: pickerModeToolbar

    ListView {
        id: calendarsList

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            topMargin: units.gu(2)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        model : root.model.getCollections();
        delegate: delegateComp

        Component{
            id: delegateComp
            Empty{
                Row{
                    width: parent.width
                    height:checkBox.height + units.gu(2)
                    spacing: units.gu(1)

                    UbuntuShape{
                        width: parent.height
                        height: parent.height - units.gu(2)
                        color: modelData.color
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                //popup dialog
                                var dialog = PopupUtils.open(Qt.resolvedUrl("ColorPickerDialog.qml"),root);
                                dialog.accepted.connect(function(color) {
                                    var collection = root.model.collection(modelData.collectionId);
                                    collection.color = color;
                                    root.model.saveCollection(collection);
                                })
                            }
                        }
                    }
                    Label{
                        text: modelData.name
                        fontSize: "medium"
                        width: parent.width - (parent.height*2)
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                checkBox.checked = !checkBox.checked
                                modelData.setExtendedMetaData("collection-selected",checkBox.checked)
                                var collection = root.model.collection(modelData.collectionId);
                                root.model.saveCollection(collection);
                            }
                        }
                    }
                    CheckBox {
                        id: checkBox
                        checked: modelData.extendedMetaData("collection-selected")
                        anchors.verticalCenter: parent.verticalCenter
                        visible:  !root.isInEditMode
                        onCheckedChanged: {
                            modelData.setExtendedMetaData("collection-selected",checkBox.checked)
                            var collection = root.model.collection(modelData.collectionId);
                            root.model.saveCollection(collection);
                        }
                    }
                }
            }
        }
    }
}
