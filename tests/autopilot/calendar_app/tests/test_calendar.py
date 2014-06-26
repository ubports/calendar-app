# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013, 2014 Canonical Ltd
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

"""Calendar app autopilot tests."""

from __future__ import absolute_import
from autopilot.matchers import Eventually
from testtools.matchers import Not, Is, NotEquals
from calendar_app.tests import CalendarTestCase

import time


class TestMainView(CalendarTestCase):

    def test_new_event(self):
        """test add new event """
        # go to today
        self.main_view.switch_to_tab("dayTab")
        header = self.main_view.get_header()
        header.click_action_button('todaybutton')
        num_events = self.main_view.get_num_events()

        # click on new event button
        header = self.main_view.get_header()
        header.click_action_button('neweventbutton')
        self.assertThat(self.main_view.get_new_event,
                        Eventually(Not(Is(None))))

        # due to https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1326963
        # the first event triggered is ignored, so we trigger an event
        # and a small sleep to clear before continuing input
        event_name_field = self.main_view.get_new_event_name_input_box()
        self.pointing_device.click_object(event_name_field)
        time.sleep(1)

        # input a new event name
        eventTitle = "Test event " + str(int(time.time()))
        self.main_view.get_new_event_name_input_box().write(eventTitle)

        # input description
        self.main_view.get_event_description_field(). \
            write("My favorite test event")

        # input location
        self.main_view.get_event_location_field().write("England")

        # input guests
        self.main_view.get_event_people_field().write("me, myself, and I")

        # todo: iterate over all combinations
        # and include recurrence and reminders

        # click save button
        save_button = self.main_view.get_new_event_save_button()
        self.pointing_device.click_object(save_button)

        # verify that the event has been created in timeline
        self.main_view.switch_to_tab("dayTab")
        header = self.main_view.get_header()
        header.click_action_button('todaybutton')
        self.assertThat(self.main_view.get_num_events,
                        Eventually(NotEquals(num_events)))

        # todo: verify entered event data
