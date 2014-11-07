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

import os
import shutil
import logging

import fixtures
import calendar_app
from address_book_service_testability import fixture_setup

from autopilot.testcase import AutopilotTestCase
from autopilot import logging as autopilot_logging

import ubuntuuitoolkit
from ubuntuuitoolkit import base

logger = logging.getLogger(__name__)


class BaseTestCaseWithPatchedHome(AutopilotTestCase):

    """A common test case class that provides several useful methods for
    calendar-app tests.

    """

    local_location = os.path.dirname(os.path.dirname(os.getcwd()))
    local_location_qml = os.path.join(local_location, 'calendar.qml')
    installed_location_qml = "/usr/share/calendar-app/calendar.qml"

    def get_launcher_and_type(self):
        if os.path.exists(self.local_location_qml):
            launcher = self.launch_test_local
            test_type = 'local'
        elif os.path.exists(self.installed_location_qml):
            launcher = self.launch_test_installed
            test_type = 'deb'
        else:
            launcher = self.launch_test_click
            test_type = 'click'
        return launcher, test_type

    def setUp(self):
        super(BaseTestCaseWithPatchedHome, self).setUp()
        self.launcher, self.test_type = self.get_launcher_and_type()
        self.home_dir = self.patch_home()

    @autopilot_logging.log_action(logger.info)
    def launch_test_local(self):
        return self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.local_location_qml,
            app_type='qt',
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    @autopilot_logging.log_action(logger.info)
    def launch_test_installed(self):
        return self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.installed_location_qml,
            app_type='qt',
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    @autopilot_logging.log_action(logger.info)
    def launch_test_click(self):
        return self.launch_click_package(
            "com.ubuntu.calendar",
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    def _copy_xauthority_file(self, directory):
        """ Copy .Xauthority file to directory, if it exists in /home
        """
        # If running under xvfb, as jenkins does,
        # xsession will fail to start without xauthority file
        # Thus if the Xauthority file is in the home directory
        # make sure we copy it to our temp home directory

        xauth = os.path.expanduser(os.path.join(os.environ.get('HOME'),
                                   '.Xauthority'))
        if os.path.isfile(xauth):
            logger.debug("Copying .Xauthority to %s" % directory)
            shutil.copyfile(
                os.path.expanduser(os.path.join(os.environ.get('HOME'),
                                   '.Xauthority')),
                os.path.join(directory, '.Xauthority'))

    def patch_home(self):
        """ mock /home for testing purposes to preserve user data
        """

        # if running on non-phablet device,
        # run in temp folder to avoid mucking up home
        # bug 1316746
        # bug 1376423
        if self.test_type is 'click':
            # just use home for now on devices
            temp_dir = os.environ.get('HOME')
        else:
            temp_dir_fixture = fixtures.TempDir()
            self.useFixture(temp_dir_fixture)
            temp_dir = temp_dir_fixture.path

            # before we set fixture, copy xauthority if needed
            self._copy_xauthority_file(temp_dir)
            self.useFixture(fixtures.EnvironmentVariable('HOME',
                                                         newvalue=temp_dir))

            logger.debug("Patched home to fake home directory %s" % temp_dir)
            self.setup_evolution()
        return temp_dir

    def setup_evolution(self):
        """restart evolution under our fake home fixture
           so there are no pre-existing events """

        if self.test_type is 'click':
            # do nothing for now on click
            return
        else:
            # from lp:qtorganizer5-eds
            # upstream patches XDG folders and other env vars
            # seems it's enough to kill the evolution daemons
            # they will restart when needed (during app launch)
            # to clean up we will again kill them
            # to restore proper function to host system

            os.system('/usr/lib/evolution/evolution-calendar-factory &')
            os.system('/usr/lib/evolution/evolution-source-registry &')

            self.addCleanup(os.system,
                            '/usr/lib/evolution/evolution-calendar-factory &')
            self.addCleanup(os.system,
                            '/usr/lib/evolution/evolution-source-registry &')
            logger.debug("Restarted evolution daemons")


class CalendarAppTestCase(BaseTestCaseWithPatchedHome):

    """Base test case that launches the calendar-app."""

    def setUp(self):
        super(CalendarAppTestCase, self).setUp()
        self.app = calendar_app.CalendarApp(self.launcher(), self.test_type)


class CalendarAppTestCaseWithVcard(BaseTestCaseWithPatchedHome):

    """Launch the calendar-app with vcard for contact support"""

    def setup_vcard(self):
        if self.test_type is 'deb':
            location = '/usr/lib/python3/dist-packages/calendar_app'
        elif self.test_type is 'click':
            location = os.path.dirname(os.path.dirname(os.getcwd()))
        else:
            location = os.path.join(
                os.path.dirname(os.path.dirname(os.getcwd())),
                'tests/autopilot/calendar_app')
        vcard = os.path.join(location, 'vcard.vcf')
        logger.debug('Using vcard from %s', vcard)
        contacts_backend = fixture_setup.AddressBookServiceDummyBackend(
            vcard=vcard)
        self.useFixture(contacts_backend)

    def setUp(self):
        super(CalendarAppTestCaseWithVcard, self).setUp()
        self.setup_vcard()
        self.app = calendar_app.CalendarApp(self.launcher(), self.test_type)
