import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Dialog {
    id: dialogue

    property var event;

    signal deleteEvent(var eventId);

    title: event.parentId ?
               i18n.tr("Delete Recurring Event"):
               i18n.tr("Delete Event") ;

    text: event.parentId ?
              i18n.tr('Delete only this event "'+event.displayLabel+'", or all events in the series?'):
              i18n.tr('Are you sure you want to delete the event "'+ event.displayLabel +'"?');

    Button {
        text: i18n.tr("Delete series")
        color: UbuntuColors.orange
        onClicked: {
            dialogue.deleteEvent(event.parentId);
            PopupUtils.close(dialogue)
        }
        visible: event.parentId !== undefined
    }

    Button {
        text: event.parentId ? i18n.tr("Delete this") : i18n.tr("Delete")
        color: UbuntuColors.orange
        onClicked: {
            dialogue.deleteEvent(event.itemId);
            PopupUtils.close(dialogue)
        }
    }

    Button {
        text: i18n.tr("Cancel")
        onClicked: PopupUtils.close(dialogue)
    }
}
