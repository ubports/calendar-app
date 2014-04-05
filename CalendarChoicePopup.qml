import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import QtOrganizer 5.0

import "GlobalEventModel.js" as GlobalModel

Page {
    id: root
    title: i18n.tr("Calendars")

    Component.onCompleted: {
        pageStack.header.visible = true;
    }

    property bool isInEditMode: false

    ToolbarItems {
        id: pickerModeToolbar
        //keeping toolbar always open
        opened: true
        locked: true
        visible: !isInEditMode

        back: ToolbarButton {
            objectName: "eventCancelButton"
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
                text: i18n.tr("Edit");
                iconName: "edit"
                onTriggered: {
                    root.isInEditMode = true
                }
            }
        }

        ToolbarButton {
            objectName: "eventSaveButton"
            action: Action {
                text: i18n.tr("Save");
                iconSource: Qt.resolvedUrl("save.svg");
                onTriggered: {
                    var collectionIds = [];
                    var collections = calendarsList.model;
                    for(var i=0; i < collections.length ; ++i) {
                        var collection = collections[i]
                        if(collection.extendedMetaData("collection-selected") === true) {
                            collectionIds.push(collection.collectionId);
                        }
                    }

                    var calFilter =  Qt.createQmlObject("import QtOrganizer 5.0; CollectionFilter{}", root, "CalendarChoice.qml");
                    calFilter.ids = collectionIds;
                    GlobalModel.globalModel().filter = calFilter;
                    pageStack.pop();
                }
            }
        }
    }

    ToolbarItems {
        id: editModeToolbar
        //keeping toolbar always open
        opened: true
        locked: true
        visible: isInEditMode

        back: ToolbarButton {
            objectName: "eventCancelButton"
            action: Action {
                text: i18n.tr("Back");
                iconName: "back"
                onTriggered: {
                    root.isInEditMode = false
                }
            }
        }
    }

    tools: isInEditMode ? editModeToolbar : pickerModeToolbar

    ListView {
        id: calendarsList
        property var filters;

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            topMargin: units.gu(2)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        model : GlobalModel.globalModel().getCollections();
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
                    }
                    Label{
                        text: modelData.name
                        fontSize: "large"
                        width: parent.width - (parent.height*2)
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(isInEditMode){
                                    //popup dialog
                                    var dialog = PopupUtils.open(Qt.resolvedUrl("ColorPickerDialog.qml"),root);
                                    dialog.accepted.connect(function(color) {
                                        var collection = GlobalModel.globalModel().collection(modelData.collectionId);
                                        collection.color = color;
                                        GlobalModel.globalModel().saveCollection(collection);
                                    })
                                } else {
                                    checkBox.checked = !checkBox.checked
                                    calendarsList.filter[modelData.collectionId] = checkBox.checked;
                                }
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
                        }
                    }
                }
            }
        }
    }
}
