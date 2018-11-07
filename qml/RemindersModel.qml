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
import Ubuntu.Components 1.3

ListModel {
    id: reminderModel

    property bool ready: false

    signal loaded()

    function intervalToString(interval) {
        if (interval < 0)
            return i18n.tr("No Reminder")

        if (interval === 0)
            return i18n.tr("On Event")

        var result = ""

        // Weeks
        var weeks = 0
        if (interval >= 604800) {
            weeks = Math.floor(interval/604800)
            interval = interval % 604800
            result = result + i18n.tr("%1 week", "%1 weeks", weeks).arg(weeks)
        }

        // Days
        var days = 0
        if (interval >= 86400) {
            days = Math.floor(interval/86400)
            interval = interval % 86400
            if (result.length > 0) {
                result = result + " "
            }
            result = result + i18n.tr("%1 day", "%1 days", days).arg(days)
        }

        // Hours
        var hours = 0
        if (interval >= 3600) {
            hours = Math.floor(interval/3600)
            interval = interval % 3600
            if (result.length > 0) {
                result = result + " "
            }
            result = result + i18n.tr("%1 hour", "%1 hours", hours).arg(hours)

        }

        if (interval > 0) {
            var minutes = Math.floor(interval/60)
            if (result.length > 0) {
                result = result + " "
            }
            result = result + i18n.tr("%1 minute", "%1 minutes", minutes).arg(minutes)
        }

        return result
    }

    function indexFromInterval(interval)
    {
        for (var i=0; i<reminderModel.count; ++i) {
            if (reminderModel.get(i).value == interval)
                return i
        }

        // custom
        return -1
    }

    function intervalFromIndex(index)
    {
        return reminderModel.get(index).value
    }

    function reset()
    {
        clear()
        reminderModel.append({ "label": i18n.tr("No Reminder"), "value": -1 })
        // TRANSLATORS: this refers to when a reminder should be shown as a notification
        // in the indicators. "On Event" means that it will be shown right at the time
        // the event starts, not any time before
        reminderModel.append({ "label": i18n.tr("On Event"), "value": 0 })
        reminderModel.append({ "label": i18n.tr("5 minutes"), "value": 300 })
        reminderModel.append({ "label": i18n.tr("10 minutes"), "value": 600 })
        reminderModel.append({ "label": i18n.tr("15 minutes"), "value": 900 })
        reminderModel.append({ "label": i18n.tr("30 minutes"), "value": 1800 })
        reminderModel.append({ "label": i18n.tr("1 hour"), "value": 3600 })
        reminderModel.append({ "label": i18n.tr("2 hours"), "value": 7200 })
        reminderModel.append({ "label": i18n.tr("1 day"), "value": 86400 })
        reminderModel.append({ "label": i18n.tr("2 days"), "value": 172800 })
        reminderModel.append({ "label": i18n.tr("1 week"), "value": 604800 })
        reminderModel.append({ "label": i18n.tr("2 weeks"), "value": 1209600 })
        reminderModel.append({ "label": i18n.tr("Custom"), "value": -2 })
    }

    Component.onCompleted: {
        reset()
        ready = true
        reminderModel.loaded()
    }
}

