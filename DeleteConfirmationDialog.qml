/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0

Dialog {
    id: dialogue
    objectName: "deleteConfirmationDialog"

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
        objectName: "deleteEventButton"
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
