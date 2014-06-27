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

import logging
import time
import uuid

from autopilot.matchers import Eventually
from testtools.matchers import HasLength, Is, Not, NotEquals

from calendar_app import data
from calendar_app.tests import CalendarTestCase


logger = logging.getLogger(__name__)


class NewEventTestCase(CalendarTestCase):

    # TODO add tests for events in the future and in the past, all day event,
    # event with recurrence and event with reminders. --elopio - 2014-06-26

    def try_delete_event(self, event_name, filter_duplicates):
        try:
            day_view = self.main_view.go_to_day_view()
            day_view.delete_event(event_name, filter_duplicates)
        except Exception as exception:
            logger.warn(str(exception))

    def test_add_new_event_with_default_values(self):
        """Test adding a new event with the default values.

        The event must be created on the currently selected date,
        with an end time, without recurrence and without reminders.

        """
        test_event = data.Event.make_unique()

        day_view = self.main_view.go_to_day_view()
        original_events = day_view.get_events()

        new_event_page = self.main_view.go_to_new_event()
        # TODO remove this once bug http://pad.lv/1334833 is fixed.
        # --elopio - 2014-06-26
        filter_duplicates = len(original_events) > 0
        self.addCleanup(
            self.try_delete_event, test_event.name, filter_duplicates)
        day_view = new_event_page.add_event(test_event)
        new_events = day_view.get_events(filter_duplicates)

        self.assertThat(new_events, HasLength(len(original_events) + 1))
        event_details_page = day_view.open_event(test_event.name)
        self.assertEqual(
            test_event, event_details_page.get_event_information())

    def test_delete_event_must_remove_it_from_day_view(self):
        """Test deleting an event must no longer show it on the day view."""
        # TODO remove the skip once the bug is fixed. --elopio - 2014-06-26
        self.skipTest('This test fails because of bug http://pad.lv/1334883')
        event = data.Event.make_unique()

        day_view = self.main_view.go_to_day_view()
        original_events = day_view.get_events()

        new_event_page = self.main_view.go_to_new_event()
        day_view = new_event_page.add_event(event)
        day_view = day_view.delete_event(event.name, len(original_events) > 0)

        events_after_delete = day_view.get_events()
        self.assertEqual(original_events, events_after_delete)

    def _test_new_event(self):
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
