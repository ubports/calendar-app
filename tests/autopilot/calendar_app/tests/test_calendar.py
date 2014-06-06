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
import datetime

from calendar_app.tests import CalendarTestCase

from ubuntuuitoolkit import (
    pickers
)


class TestMainView(CalendarTestCase):

    def test_new_event(self):
        """test add new event """
        #go to today
        self.main_view.switch_to_tab("dayTab")
        header = self.main_view.get_header()
        header.click_action_button('todaybutton')
        num_events = self.main_view.get_num_events()

        # calculate some dates
        today = self.main_view.get_day_view().currentDay.datetime
        yesterday = today + datetime.timedelta(days=-1)
        tomorrow = today + datetime.timedelta(days=1)

        start_time = datetime.time(6, 5)
        end_time = datetime.time(11, 4)

        #click on new event button
        header = self.main_view.get_header()
        header.click_action_button('neweventbutton')
        self.assertThat(self.main_view.get_new_event,
                        Eventually(Not(Is(None))))

        # Set the start date
        start_date_field = self.main_view.get_event_start_date_field()
        self.pointing_device.click_object(start_date_field)
        date_picker = self.main_view.wait_select_single(
            pickers.DatePicker, mode="Years|Months|Days", visible=True)
        date_picker.pick_date(yesterday)
        self.pointing_device.click_object(start_date_field)

        # Set the end date
        end_date_field = self.main_view.get_event_end_date_field()
        self.pointing_device.click_object(end_date_field)
        date_picker = self.main_view.wait_select_single(
            pickers.DatePicker, mode="Years|Months|Days", visible=True)
        date_picker.pick_date(tomorrow)
        self.pointing_device.click_object(end_date_field)

        # Set the start time
        start_time_field = self.main_view.get_event_start_time_field()
        self.pointing_device.click_object(start_time_field)
        time_picker = self.main_view.wait_select_single(
            pickers.DatePicker, mode='Hours|Minutes', visible=True)
        time_picker.pick_time(start_time)
        self.pointing_device.click_object(start_time_field)

        # Set the end time
        end_time_field = self.main_view.get_event_end_time_field()
        self.pointing_device.click_object(end_time_field)
        time_picker = self.main_view.wait_select_single(
            pickers.DatePicker, mode='Hours|Minutes', visible=True)
        time_picker.pick_time(end_time)
        self.pointing_device.click_object(end_time_field)

        #input a new event name
        eventTitle = "Test event " + str(int(time.time()))
        event_name_field = self.main_view.get_new_event_name_input_box()
        self.pointing_device.click_object(event_name_field)
        #due to https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1326963
        #need to tap twice
        self.pointing_device.click_object(event_name_field)
        self.assertThat(event_name_field.activeFocus, Eventually(Equals(True)))
        self.keyboard.type(eventTitle)
        self.assertThat(event_name_field.text, Eventually(Equals(eventTitle)))

        #input location
        location_field = self.main_view.get_event_location_field()
        self.pointing_device.click_object(location_field)
        self.assertThat(location_field.activeFocus, Eventually(Equals(True)))
        self.keyboard.type("My location")
        self.assertThat(location_field.text, Eventually(Equals("My location")))

        #click save button
        save_button = self.main_view.get_new_event_save_button()
        self.pointing_device.click_object(save_button)

        #verify that the event has been created in timeline
        self.main_view.switch_to_tab("dayTab")
        header = self.main_view.get_header()
        header.click_action_button('todaybutton')
        self.assertThat(self.main_view.get_num_events,
                        Eventually(NotEquals(num_events)))
