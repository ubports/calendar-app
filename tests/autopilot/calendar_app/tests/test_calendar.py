# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually

from testtools.matchers import Equals, NotEquals

import math
import time
import unittest

from calendar_app.tests import CalendarTestCase
from time import sleep


class TestMainWindow(CalendarTestCase):

    def test_timeline_view_shows(self):
        event_view = self.main_window.get_event_view()

        self.assertThat(
            event_view.eventViewType, Eventually(Equals("DiaryView.qml")))
        self.ubuntusdk.click_toolbar_button("Timeline")
        self.assertThat(
            event_view.eventViewType, Eventually(Equals("TimeLineView.qml")))
        self.ubuntusdk.click_toolbar_button("Diary")
        self.assertThat(
            event_view.eventViewType, Eventually(Equals("DiaryView.qml")))

##    @unittest.skip("Adding a new event is broken, needs fixing. "
##                   "See http://pad.lv/1206048.")

    def test_new_event(self):
        """add new event test"""

        #click on new event button
        self.ubuntusdk.click_toolbar_button('New Event')

        #grab all the fields
        #event_view = self.main_window.get_event_view()
        event_name_field = self.main_window.get_new_event_name_input_box()
        start_time_field = self.main_window.get_event_start_time_field()
        end_time_field = self.main_window.get_event_end_time_field()
        location_field = self.main_window.get_event_location_field()
        people_field = self.main_window.get_event_people_field()
        save_button = self.main_window.get_event_save_button()

        #input a new event name
        eventTitle = "Test event" + str(time.time())

        self.pointing_device.click_object(event_name_field)
        self.keyboard.type(eventTitle)
        self.assertThat(event_name_field.text, Eventually(Equals(eventTitle)))

        #input start time
        self.pointing_device.click_object(start_time_field)

        timePicker = self.app.select_single("TimePicker")
        self.assertThat(timePicker.title, Eventually(Equals("Time")))

        hourBeforeChange = timePicker.hour

        hourScroller = self.ubuntusdk.get_object("Scroller", "hourScroller")
        self.assertThat(hourScroller.visible, Eventually(Equals(True)))

        y_Hscroller = hourScroller.globalRect[1]
        height_Hscroller = hourScroller.globalRect[3]
        x_Hscroller = hourScroller.globalRect[0]
        width_Hscroller = hourScroller.globalRect[2]
        hourScrollerHeight = hourScroller.height

        self.pointing_device.drag(x_Hscroller+(width_Hscroller/4), y_Hscroller+((height_Hscroller/4)*2),
                                  x_Hscroller+(width_Hscroller/4), (y_Hscroller+((height_Hscroller/4)*2))+ hourScrollerHeight * 2)

        hourAfterChange = timePicker.hour

        self.assertThat(hourAfterChange, Eventually(Equals(hourBeforeChange - 1)))

        #click ok button
        ok_button = self.main_window.get_time_ok_button()
        self.pointing_device.click_object(ok_button)

        #input location
        self.pointing_device.click_object(location_field)
        self.keyboard.type("My location")
        self.assertThat(location_field.text, Eventually(Equals("My location")))

        #input people
        self.pointing_device.click_object(people_field)
        self.keyboard.type("Me")
        self.assertThat(people_field.text, Eventually(Equals("Me")))


##
##        #verify that the event has been created in timeline
##        title_label = lambda: self.main_window.get_title_label(eventTitle)
##        self.assertThat(title_label, Eventually(NotEquals(None)))
