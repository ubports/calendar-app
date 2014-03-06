import QtQuick 2.0
import "dateExt.js" as DateExt

import QtOrganizer 5.0

OrganizerModel {
    id: eventModel
    manager:"eds"
    autoUpdate: false

    signal reloaded

    onModelChanged: {
        reloaded();
    }
}
