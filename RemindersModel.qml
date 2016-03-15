/*
 * Copyright (C) 2014 Canonical Ltd
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

import QtQuick 2.4

ListModel {
    id: reminderModel

    signal loaded()

    Component.onCompleted: {
        reminderModel.append({ "label": i18n.tr("No Reminder"), "value": -1 })
        // TRANSLATORS: this refers to when a reminder should be shown as a notification
        // in the indicators. "On Event" means that it will be shown right at the time
        // the event starts, not any time before
        reminderModel.append({ "label": i18n.tr("On Event"), "value": 0 })
        reminderModel.append({ "label": i18n.tr("5 minutes"), "value": 300 })
        reminderModel.append({ "label": i18n.tr("15 minutes"), "value": 900 })
        reminderModel.append({ "label": i18n.tr("30 minutes"), "value": 1800 })
        reminderModel.append({ "label": i18n.tr("1 hour"), "value": 3600 })
        reminderModel.append({ "label": i18n.tr("2 hours"), "value": 7200 })
        reminderModel.append({ "label": i18n.tr("1 day"), "value": 86400 })
        reminderModel.append({ "label": i18n.tr("2 days"), "value": 172800 })
        reminderModel.append({ "label": i18n.tr("1 week"), "value": 604800 })
        reminderModel.append({ "label": i18n.tr("2 weeks"), "value": 1209600 })
        reminderModel.loaded()
    }
}

