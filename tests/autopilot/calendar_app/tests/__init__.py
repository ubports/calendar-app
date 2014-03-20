# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013 Canonical Ltd
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


"""calendar-app autopilot tests."""

import os.path
import os
import shutil
import logging

try:
    from unittest import mock
except ImportError:
    import mock
import tempfile

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase

from ubuntuuitoolkit import emulators as toolkit_emulators
from calendar_app import emulators

logger = logging.getLogger(__name__)


class CalendarTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods for
    calendar-app tests.

    """
    if model() == 'Desktop':
        scenarios = [('with mouse', dict(input_device_class=Mouse))]
    else:
        scenarios = [('with touch', dict(input_device_class=Touch))]

    local_location = "../../calendar.qml"
    installed_location = "/usr/share/calendar-app/calendar.qml"

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        self.home_dir = self._patch_home()
        super(CalendarTestCase, self).setUp()

        #turn off the OSK so it doesn't block screen elements
        if model() != 'Desktop':
            os.system("stop maliit-server")
            self.addCleanup(os.system, "start maliit-server")

        # Unset the current locale to ensure locale-specific data
        # (day and month names, first day of the week, …) doesn’t get
        # in the way of test expectations.
        self.patch_environment('LC_ALL', 'C')

        if os.path.exists(self.local_location):
            self.launch_test_local()
        elif os.path.exists(self.installed_location):
            self.launch_test_installed()
        else:
            self.launch_test_click()

    def launch_test_local(self):
        logger.debug("Running via local installation")
        self.app = self.launch_test_application(
            "qmlscene",
            self.local_location,
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_installed(self):
        logger.debug("Running via installed debian package")
        self.app = self.launch_test_application(
            "qmlscene",
            self.installed_location,
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_click(self):
        logger.debug("Running via click package")
        self.app = self.launch_click_package(
            "com.ubuntu.calendar",
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def _patch_home(self):
        #make a temp dir
        temp_dir = tempfile.mkdtemp()
        logger.debug("Created fake home directory " + temp_dir)
        self.addCleanup(shutil.rmtree, temp_dir)
        #if the Xauthority file is in home directory
        #make sure we copy it to temp home, otherwise do nothing
        xauth = os.path.expanduser(os.path.join('~', '.Xauthority'))
        if os.path.isfile(xauth):
            logger.debug("Copying .Xauthority to fake home " + temp_dir)
            shutil.copyfile(
                os.path.expanduser(os.path.join('~', '.Xauthority')),
                os.path.join(temp_dir, '.Xauthority'))
        patcher = mock.patch.dict('os.environ', {'HOME': temp_dir})
        patcher.start()
        logger.debug("Patched home to fake home directory " + temp_dir)
        self.addCleanup(patcher.stop)
        return temp_dir

    @property
    def main_view(self):
        return self.app.wait_select_single(emulators.MainView)
