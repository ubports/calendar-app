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

"""
Calendar app autopilot tests for the agenda view.
"""

from __future__ import absolute_import

import logging

from autopilot.matchers import Eventually
from testtools.matchers import Equals

from calendar_app.tests import CalendarAppTestCaseWithVcard

from calendar_app import data

logger = logging.getLogger(__name__)


class TestAgendaView(CalendarAppTestCaseWithVcard):

    def setUp(self):
        super(TestAgendaView, self).setUp()
        self.agenda_view = self.app.main_view.go_to_agenda_view()

    def test_selecting_event_opens_it(self):
        test_event = data.Event.make_unique()

        new_event_page = self.app.main_view.go_to_new_event()
        new_event_page.add_event(test_event)

        self.agenda_view.open_event(test_event.name)
        event_details_page = self.app.main_view.get_event_details()
        event_details = event_details_page.get_event_information()

        self.assertThat(
            event_details.name, Eventually(Equals(test_event.name)))
