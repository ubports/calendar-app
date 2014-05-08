import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Dialog {
    id: dialogue

    property var event;

    signal editEvent(var eventId);

    title: i18n.tr("Edit Event")

    text: i18n.tr('Edit only this event "'+event.displayLabel+'", or all events in the series?');

    Button {
        text: i18n.tr("Edit series")
        color: UbuntuColors.orange
        onClicked: {
            dialogue.editEvent(event.parentId);
            PopupUtils.close(dialogue)
        }
    }

    Button {
        text: i18n.tr("Edit this")
        color: UbuntuColors.orange
        onClicked: {
            dialogue.editEvent(event.itemId);
            PopupUtils.close(dialogue)
        }
    }

    Button {
        text: i18n.tr("Cancel")
        onClicked: PopupUtils.close(dialogue)
    }
}
