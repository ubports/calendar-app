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
        """test timeline view"""

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
        """test add new event """

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
        self.assertThat(self.main_window.get_new_event().visible, Eventually(Equals(True)))
        eventTitle = "Test event" + str(time.time())

        self.pointing_device.click_object(event_name_field)
        self.keyboard.type(eventTitle)
        self.assertThat(event_name_field.text, Eventually(Equals(eventTitle)))

        #input start time
        self.assertThat(start_time_field, NotEquals(None))
        self.pointing_device.click_object(start_time_field)

        #change hour
        timePicker = self.app.select_single("TimePicker")
        self.assertThat(timePicker.title, Eventually(Equals("Time")))

        hourBeforeChange = timePicker.hour

        hourScroller = self.ubuntusdk.get_object("Scroller", "hourScroller")
        self.assertThat(hourScroller.visible, Eventually(Equals(True)))

        y_Hscroller = hourScroller.globalRect[1]
        height_Hscroller = hourScroller.globalRect[3]
        x_Hscroller = hourScroller.globalRect[0]
        width_Hscroller = hourScroller.globalRect[2]

        self.pointing_device.drag(x_Hscroller+(width_Hscroller/4),
                                 (y_Hscroller+((height_Hscroller/4)*3)),
                                  x_Hscroller+(width_Hscroller/4),
                                 (y_Hscroller+((height_Hscroller/4)*2)))

        hourAfterChange = timePicker.hour
##        self.assertThat(hourAfterChange, Eventually(Equals(hourBeforeChange + 1)))

        #change minutes
        minutesBeforeChange = timePicker.minute
        minuteScroller = self.ubuntusdk.get_object("Scroller", "minuteScroller")
        self.assertThat(minuteScroller.visible, Eventually(Equals(True)))


        y_Mscroller = minuteScroller.globalRect[1]
        height_Mscroller = minuteScroller.globalRect[3]
        x_Mscroller = minuteScroller.globalRect[0]
        width_Mscroller = minuteScroller.globalRect[2]

        self.pointing_device.drag(x_Mscroller+(width_Mscroller/4),
                                 (y_Mscroller+((height_Mscroller/4)*3)),
                                  x_Mscroller+(width_Mscroller/4),
                                 (y_Mscroller+((height_Mscroller/4)*2)))

        minutesAfterChange = timePicker.minute
##        self.assertThat(minutesAfterChange, Eventually(NotEquals(minutesBeforeChange)))

        #click ok button
        ok_button = self.main_window.get_time_ok_button()
        self.assertThat(ok_button, NotEquals(None))
        self.pointing_device.click_object(ok_button)

        self.assertThat(self.main_window.get_new_event().visible, Eventually(Equals(True)))

        #---> TODO input end time

        #input location
        self.pointing_device.click_object(location_field)
        self.keyboard.type("My location")
        self.assertThat(location_field.text, Eventually(Equals("My location")))

        #input people
        self.pointing_device.click_object(people_field)
        self.keyboard.type("Me")
        self.assertThat(people_field.text, Eventually(Equals("Me")))

       #click save button
        save_button = self.main_window.get_event_save_button()
        self.assertThat(save_button, NotEquals(None))
        self.pointing_device.click_object(save_button)

        #verify that the event has been created in timeline
        title_label = self.main_window.get_title_label(eventTitle)
        self.assertThat(title_label, NotEquals(None))
