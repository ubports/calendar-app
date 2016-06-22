/*
 * Copyright (C) 2016 Canonical Ltd
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
import Ubuntu.Components.Popups 1.3

OptionSelectorPage {
    id: optionSelectorPage

    property int interval: -1

    function refresh()
    {
        if (!model.ready)
            return

        var newIndex = model.indexFromInterval(interval)
        // append custom interval
        if (newIndex === -1) {
            var strInteval = model.intervalToString(interval)
            var value = { "label": strInteval, "value": interval }

            // find position for new interval
            for (var i=0; i<model.count; ++i) {
                if (model.get(i).value > interval) {
                    model.insert(i, value)
                    newIndex = i
                    break
                }
            }

            if (newIndex === -1) {
                model.append(value)
                newIndex = (model.count - 1)
            }
        }

        selectedIndex = newIndex
    }

    Component {
        id: dialogCustomInterval
        Dialog {
            id: dialog

            title: i18n.tr("Custom reminder")
            text: "How many minutes before event?"
            TextField {
                id: customInteval

                validator: IntValidator{ bottom: 1; }
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: {
                    selectedIndex = model.indexFromInterval(interval)
                    PopupUtils.close(dialog)
                }
            }
            Button {
                enabled: !!customInteval.text.trim()
                text: i18n.tr("Ok")
                onClicked: {
                    if (customInteval.text > 0) {
                        var minutes = parseInt(customInteval.text.trim())
                        if (minutes > 0) {
                            optionSelectorPage.interval = minutes * 60
                            optionSelectorPage.refresh()
                        }
                    }
                    PopupUtils.close(dialog)
                }
            }
        }
    }

    model: RemindersModel {
        onLoaded: refresh()
    }
    onSelectedIndexChanged: {
        var newInterval = model.intervalFromIndex(selectedIndex)
        if (newInterval === -2) {
            PopupUtils.open(dialogCustomInterval)
        } else {
            interval = newInterval
        }
    }
}
