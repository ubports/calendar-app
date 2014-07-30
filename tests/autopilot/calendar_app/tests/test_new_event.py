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
from testtools.matchers import Equals

from calendar_app import data
from calendar_app.tests import CalendarTestCase


logger = logging.getLogger(__name__)


class NewEventTestCase(CalendarTestCase):

    # TODO add tests for events in the future and in the past, all day event,
    # event with recurrence and event with reminders.
    # also add tests for saving to different calendars
    # We currently can't change the date of the new event because of bug
    # http://pad.lv/1328600 on Autopilot.
    # --elopio - 2014-06-26

    def _try_delete_event(self, event_name):
        try:
            day_view = self.main_view.go_to_day_view()
            day_view.delete_event(event_name)
        except Exception as exception:
            logger.warn(str(exception))

    def _add_event(self):
        test_event = data.Event.make_unique()
        day_view = self.main_view.go_to_day_view()

        new_event_page = self.main_view.go_to_new_event()
        new_event_page.add_event(test_event)

        return day_view, test_event

    # TODO, add test to check events are displayed properly
    # after multiple operations

    def test_add_new_event_with_default_values(self):
        """Test adding a new event with the default values.

        The event must be created on the currently selected date,
        with an end time, without recurrence and without reminders.

        """
        day_view, test_event = self._add_event()

        self.addCleanup(self._try_delete_event, test_event.name)
        self.assertThat(lambda: day_view.get_event(test_event.name),
                        Eventually(Equals(True)))
        event_details_page = day_view.open_event(test_event.name)
        self.assertEqual(
            test_event, event_details_page.get_event_information())


    def test_delete_event_must_remove_it_from_day_view(self):
        """Test deleting an event must no longer show it on the day view."""
        day_view, test_event = self._add_event()

        day_view = day_view.delete_event(test_event.name)

        self.assertThat(lambda: day_view.get_event(test_event.name),
                        Eventually(Equals(False)))
