# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2014 Canonical Ltd
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

from calendar_app import data, tests
from address_book_service_testability import fixture_setup


class NewEventFormTestCase(tests.CalendarAppTestCase):

    # TODO once address_book_service_testability is packaged, remove
    # packing the modules as part of testcase

    def setUp(self):
        contacts_backend = fixture_setup.AddressBookServiceDummyBackend()
        self.useFixture(contacts_backend)
        super(NewEventFormTestCase, self).setUp()

    def test_fill_form(self):
        """Test that the form can be filled with event information."""
        test_event = data.Event.make_unique(unique_id='test uuid')

        new_event_page = new_event_page = self.app.main_view.go_to_new_event()
        new_event_page._fill_form(test_event)

        form_values = new_event_page._get_form_values()
        self.assertEqual(test_event, form_values)
