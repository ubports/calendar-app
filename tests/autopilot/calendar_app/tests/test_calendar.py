# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually

from testtools.matchers import Equals, Not, Is, NotEquals

import time

from calendar_app.tests import CalendarTestCase


class TestMainView(CalendarTestCase):

    def scroll_time_picker_to_time(self, picker, hours, minutes):
        # Scroll hours to selected value
        scroller = picker.select_single("Scroller", objectName="hourScroller")
        x = int(scroller.globalRect[0] + scroller.globalRect[2] / 2)
        y = int(scroller.globalRect[1] + 0.9 * scroller.globalRect[3])
        self.pointing_device.move(x, y)
        while (scroller.currentIndex != hours):
            current_index = scroller.currentIndex
            self.pointing_device.click()
            self.assertThat(scroller.currentIndex, Eventually(
                Equals((current_index + 1) % 24)))

        # Scroll minutes to selected value
        scroller = picker.select_single("Scroller",
                                        objectName="minuteScroller")
        x = int(scroller.globalRect[0] + scroller.globalRect[2] / 2)
        y = int(scroller.globalRect[1] + 0.9 * scroller.globalRect[3])
        self.pointing_device.move(x, y)
        while (scroller.currentIndex != minutes):
            current_index = scroller.currentIndex
            self.pointing_device.click()
            self.assertThat(scroller.currentIndex, Eventually(
                Equals((current_index + 1) % 60)))

    def test_new_event(self):
        """test add new event """
        #go to today
        self.main_view.switch_to_tab("dayTab")
        self.main_view.open_toolbar().click_button("todaybutton")
        num_events = self.main_view.get_num_events()

        #click on new event button
        self.main_view.open_toolbar().click_button("neweventbutton")
        self.assertThat(self.main_view.get_new_event,
                        Eventually(Not(Is(None))))

        #input a new event name
        eventTitle = "Test event " + str(int(time.time()))
        event_name_field = self.main_view.get_new_event_name_input_box()
        self.pointing_device.click_object(event_name_field)
        self.assertThat(event_name_field.activeFocus, Eventually(Equals(True)))
        self.keyboard.type(eventTitle)
        self.assertThat(event_name_field.text, Eventually(Equals(eventTitle)))

        # Set the start time
        start_time_field = self.main_view.get_event_start_time_field()
        self.pointing_device.click_object(start_time_field)
        picker = self.main_view.get_time_picker()
        self.scroll_time_picker_to_time(picker, 12, 28)
        ok = picker.select_single("Button", objectName="TimePickerOKButton")
        self.pointing_device.click_object(ok)

        ## Set the end time
        end_time_field = self.main_view.get_event_end_time_field()
        self.pointing_device.click_object(end_time_field)
        picker = self.main_view.get_time_picker()
        self.scroll_time_picker_to_time(picker, 13, 38)
        ok = picker.select_single("Button", objectName="TimePickerOKButton")
        self.pointing_device.click_object(ok)

        #input location
        location_field = self.main_view.get_event_location_field()
        self.pointing_device.click_object(location_field)
        self.assertThat(location_field.activeFocus, Eventually(Equals(True)))
        self.keyboard.type("My location")
        self.assertThat(location_field.text, Eventually(Equals("My location")))

        #click save button
        self.main_view.open_toolbar().click_button("eventSaveButton")

        #verify that the event has been created in timeline
        self.main_view.open_toolbar().click_button("todaybutton")
        self.assertThat(self.main_view.get_num_events,
                        Eventually(NotEquals(num_events)))
