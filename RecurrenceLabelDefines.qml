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

import QtQuick 2.3
import Ubuntu.Components 1.1

QtObject {
    property var recurrenceLabel:[i18n.tr("Once"),
        i18n.tr("Daily"),
        i18n.tr("On Weekdays"),
        // TRANSLATORS: The arguments refer to days of the week. E.g. "On Monday, Tuesday, Thursday"
        i18n.tr("On %1, %2 ,%3").arg(Qt.locale().dayName(Qt.Monday,Locale.NarrowFormat)).arg(Qt.locale().dayName(Qt.Wednesday,Locale.NarrowFormat)).arg(Qt.locale().dayName(Qt.Friday,Locale.NarrowFormat)),
        // TRANSLATORS: The arguments refer to days of the week. E.g. "On Monday and Thursday"
        i18n.tr("On %1 and %2").arg(Qt.locale().dayName(Qt.Tuesday,Locale.NarrowFormat)).arg(Qt.locale().dayName(Qt.Thursday,Locale.NarrowFormat)),
        i18n.tr("Weekly"),
        i18n.tr("Monthly"),
        i18n.tr("Yearly")];
}
