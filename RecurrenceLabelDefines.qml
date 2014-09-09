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

QtObject {
    property var recurrenceLabel:[i18n.tr("Once"),
        i18n.tr("Daily"),
        i18n.tr("On Weekdays"),
        i18n.tr("On Monday, Wednesday and Friday"),
        i18n.tr("On Tuesday and Thursday"),
        i18n.tr("Weekly"),
        i18n.tr("Monthly"),
        i18n.tr("Yearly")];
}
