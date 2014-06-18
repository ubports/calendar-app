# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot tests."""

from __future__ import absolute_import
from autopilot.matchers import Eventually
from testtools.matchers import Not, Is, NotEquals
from calendar_app.tests import CalendarTestCase

import time
#import datetime


class TestMainView(CalendarTestCase):

    def test_new_event(self):
        """test add new event """
        #go to today
        self.main_view.switch_to_tab("dayTab")
        header = self.main_view.get_header()
        header.click_action_button('todaybutton')
        num_events = self.main_view.get_num_events()

        # calculate some dates
        #today = self.main_view.get_day_view().currentDay.datetime
        #yesterday = today + datetime.timedelta(days=-1)
        #tomorrow = today + datetime.timedelta(days=1)

        #start_time = datetime.time(6, 5)
        #end_time = datetime.time(11, 38)

        #click on new event button
        header = self.main_view.get_header()
        header.click_action_button('neweventbutton')
        self.assertThat(self.main_view.get_new_event,
                        Eventually(Not(Is(None))))

        #due to https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1326963
        #the first event triggered is ignored, so we trigger an event
        #and a small sleep to clear before continuing input
        event_name_field = self.main_view.get_new_event_name_input_box()
        self.pointing_device.click_object(event_name_field)
        time.sleep(1)

        #due to https://bugs.launchpad.net/ubuntu-calendar-app/+bug/1328600
        #we cannot interact to set date / time, so disabling this for now

        # Set the start date
        #self.main_view.set_picker(self.main_view.get_event_start_date_field(),
        #                          'date',
        #                          yesterday)

        # Set the end date
        #self.main_view.set_picker(self.main_view.get_event_end_date_field(),
        #                          'date',
        #                          tomorrow)

        # Set the start time
        #self.main_view.set_picker(self.main_view.get_event_start_time_field(),
        #                          'time',
        #                          start_time)

        # Set the end time
        #self.main_view.set_picker(self.main_view.get_event_end_time_field(),
        #                          'time',
        #                          end_time)

        #input a new event name
        eventTitle = "Test event " + str(int(time.time()))
        self.main_view.get_new_event_name_input_box().write(eventTitle)

        #input description
        self.main_view.get_event_description_field(). \
            write("My favorite test event")

        #input location
        self.main_view.get_event_location_field().write("England")

        #input guests
        #self.main_view.get_event_people_field().write("me, myself, and I")

        #todo: iterate over all combinations
        #and include recurrence and reminders

        #click save button
        save_button = self.main_view.get_new_event_save_button()
        self.pointing_device.click_object(save_button)

        #verify that the event has been created in timeline
        self.main_view.switch_to_tab("dayTab")
        header = self.main_view.get_header()
        header.click_action_button('todaybutton')
        self.assertThat(self.main_view.get_num_events,
                        Eventually(NotEquals(num_events)))

        #todo: verify entered event data
