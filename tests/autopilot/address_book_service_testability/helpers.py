# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright 2014 Canonical Ltd.
#
# This file is part of address-book-service tests.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>

import dbus

DBUS_IFACE_ADD_BOOK = 'com.canonical.pim.AddressBook'
DBUS_IFACE_ADD_BOOKVIEW = 'com.canonical.pim.AddressBookView'

bus = dbus.SessionBus()


def query_contacts(fields='', query='', sources=[]):
    iface = _get_contacts_dbus_service_iface()
    view_path = iface.query(fields, query, [])
    view = bus.get_object(
        'com.canonical.pim', view_path)
    view_iface = dbus.Interface(
        view, dbus_interface=DBUS_IFACE_ADD_BOOKVIEW)
    contacts = view_iface.contactsDetails([], 0, -1)
    view.close()
    return contacts


def _get_contacts_dbus_service_iface():
    proxy = bus.get_object(
        'com.canonical.pim', '/com/canonical/pim/AddressBook')
    return dbus.Interface(proxy, 'com.canonical.pim.AddressBook')
