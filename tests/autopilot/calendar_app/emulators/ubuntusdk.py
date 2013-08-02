# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Authored by: Nicholas Skaggs <nicholas.skaggs@canonical.com>


class ubuntusdk(object):
    """An emulator class that makes it easy to interact with the ubuntu sdk
    applications."""

    def __init__(self, autopilot, app):
        self.app = app
        self.autopilot = autopilot

    def get_qml_view(self):
        """Get the main QML view"""
        return self.app.select_single("QQuickView")

    def get_object(self, typeName, name):
        """Get a specific object"""
        return self.app.select_single(typeName, objectName=name)

    def get_objects(self, typeName, name):
        """Get more than one object"""
        return self.app.select_many(typeName, objectName=name)

    def get_tabs(self):
        """Return all tabs"""
        return self.app.select_single("Tabs")

    def switch_to_tab(self, tab):
        """Switch to the specified tab number"""
        tabs = self.get_tabs()
        currentTab = tabs.selectedTabIndex

        #perform operations until tab == currentTab
        while tab != currentTab:
            if tab > currentTab:
                self._next_tab()
            if tab < currentTab:
                self._previous_tab()
            currentTab = tabs.selectedTabIndex

    def _previous_tab(self):
        """Switch to the previous tab"""
        qmlView = self.get_qml_view()

        startX = int(qmlView.x + qmlView.width * 0.10)
        stopX = int(qmlView.x + qmlView.width * 0.45)
        lineY = int(qmlView.y + qmlView.height * 0.05)

        self.autopilot.pointing_device.drag(startX, lineY, stopX, lineY)
        self.autopilot.pointing_device.move(startX, lineY)
        self.autopilot.pointing_device.click()
        self.autopilot.pointing_device.click()

    def _next_tab(self):
        """Switch to the next tab"""
        qmlView = self.get_qml_view()

        startX = int(qmlView.x + qmlView.width * 0.45)
        stopX = int(qmlView.x + qmlView.width * 0.10)
        lineY = int(qmlView.y + qmlView.height * 0.05)

        self.autopilot.pointing_device.drag(startX, lineY, stopX, lineY)
        self.autopilot.pointing_device.move(startX, lineY)
        self.autopilot.pointing_device.click()
        self.autopilot.pointing_device.click()

    def toggle_toolbar(self):
        """Toggle the toolbar between revealed and hidden"""
        #check and see if the toolbar is open or not
        if self.get_toolbar().opened:
            self.hide_toolbar()
        else:
            self.open_toolbar()

    def get_toolbar(self):
        """Returns the toolbar in the main events view."""
        return self.app.select_single("Toolbar")

    def get_toolbar_buttons(self):
        """Returns the list of buttons in the toolbar"""
        toolbar = self.get_toolbar()
        items = toolbar.select_single("ToolbarItems")
        return items.select_many("ActionItem")

    def get_toolbar_button(self, buttonLabel):
        """Returns the toolbar button with a given label"""
        # FIXME: this is not reliable as labels may be localized
        buttons = self.get_toolbar_buttons()
        for button in buttons:
            if button.text == buttonLabel:
                return button
        return None

    def click_toolbar_button(self, buttonLabel):
        """Clicks the toolbar button with buttonLabel"""
        toolbar = self.get_toolbar()
        if not toolbar.opened:
            self.open_toolbar()
        button = self.get_toolbar_button(buttonLabel)
        self.autopilot.pointing_device.click_object(button)

    def open_toolbar(self):
        """Open the toolbar"""
        qmlView = self.get_qml_view()

        lineX = int(qmlView.x + qmlView.width * 0.50)
        startY = int(qmlView.y + qmlView.height - 1)
        stopY = int(qmlView.y + qmlView.height * 0.95)

        self.autopilot.pointing_device.drag(lineX, startY, lineX, stopY)

    def hide_toolbar(self):
        """Hide the toolbar"""
        qmlView = self.get_qml_view()

        lineX = int(qmlView.x + qmlView.width * 0.50)
        startY = int(qmlView.y + qmlView.height * 0.95)
        stopY = int(qmlView.y + qmlView.height - 1)

        self.autopilot.pointing_device.drag(lineX, startY, lineX, stopY)

    def set_popup_value(self, popover, button, value):
        """Changes the given popover selector to the request value
        At the moment this only works for values that are currently visible. To
        access the remaining items, a help method to drag and recheck is
        needed."""
        #The popover is assumed to be the following format
        #Component {
        #    id: actionSelectionPopover
        #
        #ActionSelectionPopover {
        #                actions: ActionList {
        #                    Action {

        popList = self.get_object("ActionSelectionPopover", popover)
        itemList = popList.select_many("Label")
        for item in itemList:
            if item.text == value:
                self.autopilot.pointing_device.click_object(item)
                return item
