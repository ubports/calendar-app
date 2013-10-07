# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually

from testtools.matchers import Equals, Not, Is

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
            self.pointing_device.click()
            scroller.currentIndex.wait_for((scroller.currentIndex + 1) % 24)
        # Scroll minutes to selected value
        scroller = picker.select_single("Scroller",
                                        objectName="minuteScroller")
        x = int(scroller.globalRect[0] + scroller.globalRect[2] / 2)
        y = int(scroller.globalRect[1] + 0.9 * scroller.globalRect[3])
        self.pointing_device.move(x, y)
        while (scroller.currentIndex != minutes):
            self.pointing_device.click()
            scroller.currentIndex.wait_for((scroller.currentIndex + 1) % 60)

    def hideOSK(self):
        start_time_field = self.main_view.get_event_start_time_field()
        self.pointing_device.click_object(start_time_field)
        self.assertThat(self.main_view.get_time_picker,
                        Eventually(Not(Is(None))))
        picker = self.main_view.get_time_picker()
        cancel = picker.select_single("Button",
                                      objectName="TimePickerCancelButton")
        self.pointing_device.click_object(cancel)
        self.assertThat(self.main_view.get_time_picker, Eventually(Is(None)))

    def test_new_event(self):
        """test add new event """

        #click on new event button
        self.main_view.open_toolbar().click_button("neweventbutton")
        self.assertThat(self.main_view.get_new_event,
                        Eventually(Not(Is(None))))

        #input a new event name
        self.hideOSK()
        eventTitle = "Test event " + str(int(time.time()))
        event_name_field = self.main_view.get_new_event_name_input_box()
        self.pointing_device.click_object(event_name_field)
        self.keyboard.type(eventTitle)
        self.assertThat(event_name_field.text, Eventually(Equals(eventTitle)))

        # Set the start time
        start_time_field = self.main_view.get_event_start_time_field()
        self.pointing_device.click_object(start_time_field)
        self.assertThat(self.main_view.get_time_picker,
                        Eventually(Not(Is(None))))
        picker = self.main_view.get_time_picker()
        self.scroll_time_picker_to_time(picker, 10, 15)
        ok = picker.select_single("Button", objectName="TimePickerOKButton")
        self.pointing_device.click_object(ok)
        self.assertThat(self.main_view.get_time_picker, Eventually(Is(None)))

        # Set the end time
        end_time_field = self.main_view.get_event_end_time_field()
        self.pointing_device.click_object(end_time_field)
        self.assertThat(self.main_view.get_time_picker,
                        Eventually(Not(Is(None))))
        picker = self.main_view.get_time_picker()
        self.scroll_time_picker_to_time(picker, 11, 45)
        ok = picker.select_single("Button", objectName="TimePickerOKButton")
        self.pointing_device.click_object(ok)
        self.assertThat(self.main_view.get_time_picker, Eventually(Is(None)))

        #input location
        self.hideOSK()
        location_field = self.main_view.get_event_location_field()
        self.pointing_device.click_object(location_field)
        self.keyboard.type("My location")
        self.assertThat(location_field.text, Eventually(Equals("My location")))

        #input people
        self.hideOSK()
        people_field = self.main_view.get_event_people_field()
        self.pointing_device.click_object(people_field)
        self.keyboard.type("Me")
        self.assertThat(people_field.text, Eventually(Equals("Me")))

        #click save button
        self.main_view.open_toolbar().click_button("eventSaveButton")
        self.assertThat(self.main_view.get_new_event, Eventually(Is(None)))

        #verify that the event has been created in timeline
        self.assertThat(lambda: self.main_view.get_label_with_text(
                        eventTitle, root=self.main_view.get_day_view()),
                        Eventually(Not(Is(None))))
