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

    signal backRequested()

    property alias displayWeekNumber: weekCheckBox.checked
    property alias displayLunarCalendar: lunarCalCheckBox.checked
    property int reminderDefaultValue: -1

    visible: false

    header: PageHeader {
        title: i18n.tr("Settings")
        leadingActionBar.actions: Action {
            text: i18n.tr("Back")
            iconName: "back"
            onTriggered: settingsPage.backRequested()
        }
    }

    RemindersModel {
        id: remindersModel
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
                }
            }
        }

        ListItem {
            id: defaultReminderItem

            visible: defaultReminderOptionSelector.model && defaultReminderOptionSelector.model.count > 0
            height: visible ? defaultReminderLayout.height + divider.height : 0

            Connections {
                target: remindersModel
                onLoaded: {
                    if (!defaultReminderOptionSelector.model) {
                        return
                    }

                    for (var i=0; i<defaultReminderOptionSelector.model.count; ++i) {
                        var reminder = defaultReminderOptionSelector.model.get(i)
                        if (reminder.value === settingsPage.reminderDefaultValue) {
                            defaultReminderOptionSelector.selectedIndex = i
                            return
                        }
                    }

                    defaultReminderOptionSelector.selectedIndex = 0
                }
            }

            SlotsLayout {
                id: defaultReminderLayout

                mainSlot: Item {
                    height: defaultReminderOptionSelector.height

                    OptionSelector {
                        id: defaultReminderOptionSelector

                        text: i18n.tr("Default reminder")
                        model: remindersModel
                        containerHeight: itemHeight * 4

                        delegate: OptionSelectorDelegate {
                            text: label
                            height: units.gu(4)
                        }

                       onDelegateClicked: settingsPage.reminderDefaultValue = model.get(index).value
                    }
                }
            }
        }
    }
}
