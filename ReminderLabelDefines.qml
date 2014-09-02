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
import QtQuick 2.0;
import Ubuntu.Components 1.1;
QtObject {
    property var reminderLabel:[i18n.tr("No Reminder"),
        i18n.tr("5 minutes"),
        i18n.tr("15 minutes"),
        i18n.tr("30 minutes"),
        i18n.tr("1 hour"),
        i18n.tr("2 hours"),
        i18n.tr("1 day"),
        i18n.tr("2 days"),
        i18n.tr("1 week"),
        i18n.tr("2 weeks")];
}
