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

import uuid


class DataMixin(object):

    """Mixin with common methods for data objects."""

    def __repr__(self):
        return '%s(%r)' % (self.__class__, self.__dict__)

    def __eq__(self, other):
        return (isinstance(other, self.__class__) and
                self.__dict__ == other.__dict__)

    def __ne__(self, other):
        return not self.__eq__(other)


class Event(DataMixin):

    """Event data object for user acceptance tests."""

    def __init__(self, name, description, location):
        # TODO add start date and end date, is all day event, recurrence and
        # reminders. --elopio - 2014-06-26
        super(Event, self).__init__()
        self.name = name
        self.description = description
        self.location = location
        # self.guests = guests

    @classmethod
    def make_unique(cls, unique_id=None):
        """Return a unique event."""
        if unique_id is None:
            unique_id = str(uuid.uuid1())
        name = 'Test event {}'.format(unique_id)
        description = 'Test description {}.'.format(unique_id)
        location = 'Test location {}'.format(unique_id)
        # guests = ['Test guest {} 1'.format(unique_id)]
        return cls(name, description, location)
