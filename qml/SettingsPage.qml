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
import Qt.labs.settings 1.0
import Ubuntu.Components.Pickers 1.3
import "CustomPickers"

Page {
    id: settingsPage
    objectName: "settings"

    property EventListModel eventModel
    property Settings settings: undefined

    Binding {
        target: settingsPage.settings
        property: "showWeekNumber"
        value: weekCheckBox.checked
        when: settings
    }

    Binding {
        target: settingsPage.settings
        property: "showLunarCalendar"
        value: lunarCalCheckBox.checked
        when: settings
    }

    visible: false

    header: PageHeader {
        title: i18n.tr("Settings")
        leadingActionBar.actions: Action {
            text: i18n.tr("Back")
            iconName: "back"
            onTriggered: pop()
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
                    checked: settings ? settings.showWeekNumber : false
                }
            }

            onClicked: {
                weekCheckBox.checked = !weekCheckBox.checked;
            }
        }

        ListItem {
            height: lunarCalLayout.height + divider.height
            ListItemLayout {
                id: lunarCalLayout
                title.text: i18n.tr("Display Chinese calendar")
                CheckBox {
                    id: lunarCalCheckBox
                    objectName: "lunarCalCheckbox"
                    SlotsLayout.position: SlotsLayout.Last
                    checked: settings ? settings.showLunarCalendar : false
                }
            }

            onClicked: {
                lunarCalCheckBox.checked = !lunarCalCheckBox.checked;
            }
        }

        ListItem {
            height: businessHoursLayout.height + divider.height
            width: parent.width

            ListItemLayout {
                id: businessHoursLayout
                title.text: i18n.tr("Business hours")

                height: businessStartInput.height

                Row {
                    id: businessHoursSettingRow
                    property date startDateToBeSet: new Date(0, 0, 0, settings.businessHourStart)
                    property date endDateToBeSet: new Date(0, 0, 0, settings.businessHourEnd)

                    onEndDateToBeSetChanged: setBusinessHours()
                    onStartDateToBeSetChanged: setBusinessHours()

                    function setBusinessHours() {
                        if (startDateToBeSet < endDateToBeSet) {
                            settings.businessHourStart = startDateToBeSet.getHours()
                            settings.businessHourEnd = endDateToBeSet.getHours()
                            businessStartInput.text = Qt.formatTime(startDateToBeSet, Qt.SystemLocaleShortDate);
                            businessEndInput.text = Qt.formatTime(endDateToBeSet, Qt.SystemLocaleShortDate);
                        }
                    }

                    function openDatePicker (element, caller, callerProperty, mode) {
                        element.highlighted = true;
                        var picker = NewPickerPanel.openDatePicker(caller, callerProperty, mode);
                        if (!picker) return;
                        picker.closed.connect(function () {
                            element.highlighted = false;
                        });
                    }

                    NewEventEntryField {
                        id: businessStartInput

                        objectName: "businessStartInput"
                        text: "" //Qt.formatTime(businessHoursSettingRow.startDateToBeSet, Qt.SystemLocaleShortDate);
                        visible: true

                        MouseArea{
                            anchors.fill: parent
                            onClicked: businessHoursSettingRow.openDatePicker(businessStartInput, businessHoursSettingRow, "startDateToBeSet", "Hours")
                        }
                    }

                    Label {
                        text: " - "
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                    }

                    NewEventEntryField {
                        id: businessEndInput

                        objectName: "businessEndInput"
                        text: "" //Qt.formatTime(businessHoursSettingRow.endDateToBeSet, Qt.SystemLocaleShortDate);
                        visible: true

                        MouseArea{
                            anchors.fill: parent
                            onClicked: businessHoursSettingRow.openDatePicker(businessEndInput, businessHoursSettingRow, "endDateToBeSet", "Hours")
                        }
                    }

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
                        if (reminder.value === settings.reminderDefaultValue) {
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

                       onDelegateClicked: settings.reminderDefaultValue = model.get(index).value
                    }
                }
            }
        }

        ListItem {
            visible: defaultCalendarOptionSelector.model && defaultCalendarOptionSelector.model.length > 0
            height: visible ? defaultCalendarLayout.height + divider.height : 0

            Component.onCompleted: {
                if (!eventModel || !defaultCalendarOptionSelector.model) {
                    return
                }

                var defaultCollectionId = eventModel.getDefaultCollection().collectionId
                for (var i=0; i<defaultCalendarOptionSelector.model.length; ++i) {
                    if (defaultCalendarOptionSelector.model[i].collectionId === defaultCollectionId) {
                        defaultCalendarOptionSelector.selectedIndex = i
                        return
                    }
                }

                defaultCalendarOptionSelector.selectedIndex = 0
            }

            SlotsLayout {
                id: defaultCalendarLayout

                mainSlot: Item {
                    height: defaultCalendarOptionSelector.height

                    OptionSelector {
                        id: defaultCalendarOptionSelector

                        text: i18n.tr("Default calendar")
                        model: settingsPage.eventModel ? settingsPage.eventModel.getWritableAndSelectedCollections() : []
                        containerHeight: (model && (model.length > 1) ? itemHeight * model.length : itemHeight)

                        Connections {
                            target: settingsPage.eventModel ? settingsPage.eventModel : null
                            onModelChanged: {
                                defaultCalendarOptionSelector.model = settingsPage.eventModel.getWritableAndSelectedCollections()
                            }
                            onCollectionsChanged: {
                                defaultCalendarOptionSelector.model = settingsPage.eventModel.getWritableAndSelectedCollections()
                            }
                        }

                        delegate: OptionSelectorDelegate {
                            text: modelData.name
                            height: units.gu(4)

                            UbuntuShape{
                                anchors {
                                    right: parent.right
                                    rightMargin: units.gu(4)
                                    verticalCenter: parent.verticalCenter
                                }

                                 width: height
                                 height: parent.height - units.gu(2)
                                 color: modelData.color
                            }
                        }

                        onDelegateClicked: settingsPage.eventModel.setDefaultCollection(model[index].collectionId)
                    }
                }
            }
        }
    }
}
