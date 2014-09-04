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

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from calendar_app import data
from calendar_app.tests import CalendarAppTestCaseWithVcard

logger = logging.getLogger(__name__)


class NewEventTestCase(CalendarAppTestCaseWithVcard):

    # TODO add tests for events in the future and in the past, all day event,
    # event with recurrence and event with reminders.
    # also add tests for saving to different calendars
    # We currently can't change the date of the new event because of bug
    # http://pad.lv/1328600 on Autopilot.
    # --elopio - 2014-06-26

    def _try_delete_event(self, event_name):
        try:
            day_view = self.app.main_view.go_to_day_view()
            day_view.delete_event(event_name)
        except Exception as exception:
            logger.warn(str(exception))

    def _add_event(self):
        test_event = data.Event.make_unique()
        day_view = self.app.main_view.go_to_day_view()
        start_num_events = len(day_view.get_events())

        new_event_page = self.app.main_view.go_to_new_event()
        new_event_page.add_event(test_event)

        day_view = self.app.main_view.get_day_view()

        # Wait a bit for the event to be added.
        self.assertThat(lambda: len(day_view.get_events()),
                        Eventually(Equals(start_num_events + 1)))

        return day_view, test_event

    def _edit_event(self, event_name):
        test_event = data.Event.make_unique()
        day_view = self.app.main_view.go_to_day_view()

        new_event_page = day_view.edit_event(event_name)

        new_event_page.add_event(test_event)
        return day_view, test_event

    def _event_exists(self, event_name):
        try:
            day_view = self.app.main_view.go_to_day_view()
            day_view.get_event(event_name, True)
        except Exception:
            return False
        return True

    # TODO write helpers to check all of the default values
    # then expand the asserts to ensure defaults are correct
    def test_new_event_must_start_with_default_values(self):
        """Test adding a new event default values

           Start Date: today Start Time: next half hour increment
           End Date: today End Time: 30 mins after start time
           Calendar: Personal
           All Day Event: unchecked
           Event Name: selected
           Description: blank
           Location: blank
           Guests: none
           This happens: Once
           Remind me: No Reminder
        """

        new_event_page = self.app.main_view.go_to_new_event()
        self.assertThat(new_event_page.get_calendar(), Equals('Personal'))

    def test_add_new_event_with_default_values(self):
        """Test adding a new event with the default values.

        The event must be created on the currently selected date,
        with an end time, without recurrence and without reminders."""

        day_view, test_event = self._add_event()

        self.addCleanup(self._try_delete_event, test_event.name)

        event_bubble = lambda: day_view.get_event(test_event.name)
        self.assertThat(event_bubble, Eventually(NotEquals(None)))

        event_details_page = day_view.open_event(test_event.name)

        self.assertEqual(test_event,
                         event_details_page.get_event_information())

    def test_delete_event_must_remove_it_from_day_view(self):
        """Test deleting an event must no longer show it on the day view."""
        day_view, test_event = self._add_event()

        day_view.delete_event(test_event.name)

        self.assertThat(lambda: self._event_exists(test_event.name),
                        Eventually(Equals(False)))

    def test_edit_event_with_default_values(self):
        """Test editing an event change unique values of an event."""

        day_view, original_event = self._add_event()
        day_view, edited_event = self._edit_event(original_event.name)
        self.addCleanup(self._try_delete_event, edited_event.name)

        event_details_page = self.app.main_view.get_event_details()

        self.assertEqual(edited_event,
                         event_details_page.get_event_information())
