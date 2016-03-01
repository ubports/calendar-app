/*
 * Copyright (C) 2013-2016 Canonical Ltd
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

Page {
    id: settingsPage
    objectName: "settings"

    visible: false

    header: PageHeader {
        title: i18n.tr("Settings")
        leadingActionBar.actions: Action {
            text: i18n.tr("Back")
            iconName: "back"
            onTriggered: {
                pop()
            }
        }
    }

    Component.onCompleted: {
        weekCheckBox.checked = mainView.displayWeekNumber
        lunarCalCheckBox.checked = mainView.displayLunarCalendar
    }

    Column {
        id: settingsColumn
        objectName: "settingsColumn"

        spacing: units.gu(0.5)
        anchors { top: settingsPage.header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }

        ListItem {
            height: weekNumberLayout.height + divider.height
            ListItemLayout {
                id: weekNumberLayout
                title.text: i18n.tr("Show week numbers")
                CheckBox {
                    id: weekCheckBox
                    objectName: "weekCheckBox"
                    SlotsLayout.position: SlotsLayout.Last
                    onCheckedChanged: {
                        mainView.displayWeekNumber = weekCheckBox.checked
                    }
                }
            }
        }

        ListItem {
            height: lunarCalLayout.height + divider.height
            ListItemLayout {
                id: lunarCalLayout
                title.text: i18n.tr("Show lunar calendar")
                CheckBox {
                    id: lunarCalCheckBox
                    objectName: "lunarCalCheckbox"
                    SlotsLayout.position: SlotsLayout.Last
                    onCheckedChanged: {
                        mainView.displayLunarCalendar = lunarCalCheckBox.checked
                    }
                }
            }
        }
    }
}
