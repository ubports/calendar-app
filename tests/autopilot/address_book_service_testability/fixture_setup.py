# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2014 Canonical
# Author: Omer Akram <omer.akram@canonical.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import os
import subprocess
import sysconfig
import time

from fixtures import EnvironmentVariable, Fixture


def get_service_library_path():
    """Return path of address-book-service binary directory."""
    architecture = sysconfig.get_config_var('MULTIARCH')

    return os.path.join(
        '/usr/lib/',
        architecture,
        'address-book-service/')


class AddressBookServiceDummyBackend(Fixture):
    """Fixture to load test vcard for client applications

    Call the fixture without any paramter to load a default vcard

    :parameter vcard: call the fixture with a vcard to be used by
                      test application.

    """
    def __init__(self, vcard=None):
        self.contact_data = vcard

    def setUp(self):
        super(AddressBookServiceDummyBackend, self).setUp()
        self.useFixture(SetupEnvironmentVariables(self.contact_data))
        self.useFixture(RestartService())


class SetupEnvironmentVariables(Fixture):

    def __init__(self, vcard):
        self.vcard = vcard

    def setUp(self):
        super(SetupEnvironmentVariables, self).setUp()
        self._setup_environment()

    def _setup_environment(self):
        self.useFixture(EnvironmentVariable(
            'ALTERNATIVE_CPIM_SERVICE_NAME', 'com.canonical.test.pim'))
        self.useFixture(EnvironmentVariable(
            'FOLKS_BACKEND_PATH',
            os.path.join(get_service_library_path(), 'dummy.so')))
        self.useFixture(EnvironmentVariable('FOLKS_BACKENDS_ALLOWED', 'dummy'))
        self.useFixture(EnvironmentVariable('FOLKS_PRIMARY_STORE', 'dummy'))
        self.useFixture(EnvironmentVariable(
            'ADDRESS_BOOK_SERVICE_DEMO_DATA',
            self._get_vcard_location()))

    def _get_vcard_location(self):
        if self.vcard:
            return self.vcard

        local_location = os.path.dirname(os.path.dirname(os.getcwd()))
        local_location = os.path.join(
            local_location,
            'tests/autopilot/address_book_service_testability/data/vcard.vcf')
        phablet_location = 'address_book_service_testability/data/vcard.vcf'
        bin_location = '/usr/share/address-book-service/data/vcard.vcf'
        cal_location = os.path.join('/usr/lib/python2.7/dist-packages/',
                                    'address_book_service_testability/data/',
                                    'vcard.vcf')
        if os.path.exists(local_location):
            print('Using %s for vcard' % local_location)
            return local_location
        elif os.path.exists(phablet_location):
            print('Using %s for vcard' % phablet_location)
            return phablet_location
        elif os.path.exists(cal_location):
            print('Using %s for vcard' % cal_location)
            return cal_location
        elif os.path.exists(bin_location):
            print('Using %s for vcard' % bin_location)
            return bin_location
        else:
            raise RuntimeError('No VCARD found in %s or %s or %s or %s' %
                               (local_location, bin_location,
                                cal_location, phablet_location))


class RestartService(Fixture):

    def setUp(self):
        super(RestartService, self).setUp()
        self.addCleanup(self._kill_address_book_service)
        self._restart_address_book_service()

    def _kill_address_book_service(self):
        try:
            pid = subprocess.check_output(
                ['pidof', 'address-book-service']).strip()
            subprocess.call(['kill', '-3', pid])
        except subprocess.CalledProcessError:
            # Service not running, so do nothing.
            pass

    def _restart_address_book_service(self):
        self._kill_address_book_service()
        path = os.path.join(
            get_service_library_path(), 'address-book-service')

        subprocess.Popen([path])
        # FIXME: Wait for 5 seconds before proceeding so that the
        # service starts,doing this because the dbus interface is
        # not reliable enough it seems. --om26er 23-07-2014
        time.sleep(5)
