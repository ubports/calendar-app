import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import QtOrganizer 5.0

import "GlobalEventModel.js" as GlobalModel

Page {
    id: root
    title: i18n.tr("Calendar Management")

    Component.onCompleted: {
        pageStack.header.visible = true;
    }

    property bool isInEditMode: false

    ToolbarItems {
        id: pickerModeToolbar
        //keeping toolbar always open
        opened: true
        locked: true

        back: ToolbarButton {
            objectName: "eventCancelButton"
            action: Action {
                text: i18n.tr("Back");
                iconSource: Qt.resolvedUrl("cancel.svg");
                onTriggered: {
                    pageStack.pop();
                }
            }
        }

        ToolbarButton {
            action: Action {
                text: i18n.tr("Edit");
                iconSource: Qt.resolvedUrl("save.svg");
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
                    var ids = [];
                    for(var i in calendarsList.filters) {
                        if(calendarsList.filters[i] === true) {
                            ids.push(i);
                        }
                    }
                    var calFilter =  Qt.createQmlObject("import QtOrganizer 5.0; CollectionFilter{}", root, "CalendarChoice.qml");
                    calFilter.ids = ids;
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

        back: ToolbarButton {
            objectName: "eventCancelButton"
            action: Action {
                text: i18n.tr("Back");
                iconSource: Qt.resolvedUrl("cancel.svg");
                onTriggered: {
                    root.isInEditMode = false
                }
            }
        }
    }

    tools: isInEditMode ? editModeToolbar : pickerModeToolbar

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

        delegate: delegateComp

        Connections{
            target: GlobalModel.globalModel()
            onReloaded:{
                populateModel();
            }
        }

        Component.onCompleted: {
            populateModel();
        }

        property var filters;
        function populateModel(){
            print(">>>>> -1");
            var filter = []
            var cals = GlobalModel.globalModel().collections;
            print(">>>>> -11");
            var oldFilter = GlobalModel.globalModel().filter;
            print(">>>>> 0");
            if( oldFilter ) {
                print(">>>>> 1");
                var selectIds = oldFilter.ids
                for(var i = 0 ; i < cals.length ; ++i) {
                    var cal = cals[i]
                    filter[cal.collectionId] = false;
                }
                print(">>>>> 2");
                for(var i=0;i< selectIds.length;++i){
                    filter[selectIds[i]] = true;
                }
            } else {
                for(var i = 0 ; i < cals.length ; ++i) {
                    var cal = cals[i]
                    filter[cal.collectionId] = true;
                }
            }
            model = cals;
            filters = filter;
        }

        Component{
            id: delegateComp
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
                                    //var collection = GlobalModel.globalModel().collection(modelData.collectionId);
                                    //collection.color = color;
                                    //GlobalModel.globalModel().saveCollection(collection);
                                    modelData.color = color
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
                    checked: calendarsList.filters[modelData.collectionId]
                    anchors.verticalCenter: parent.verticalCenter
                    visible:  !root.isInEditMode
                    onCheckedChanged: {
                        calendarsList.filters[modelData.collectionId] = checkBox.checked;
                    }
                }
            }
        }
    }
}
