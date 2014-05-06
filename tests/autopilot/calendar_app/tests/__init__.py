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

"""Calendar app autopilot tests."""

import tempfile
try:
    from unittest import mock
except ImportError:
    import mock
import os
import shutil
import logging

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase

from ubuntuuitoolkit import (
    base,
    emulators as toolkit_emulators,
    environment
)
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

    working_dir = os.getcwd()
    local_location_dir = os.path.dirname(os.path.dirname(working_dir))
    local_location = local_location_dir + "/calendar.qml"
    installed_location = "/usr/share/calendar/calendar.qml"

    def setup_environment(self):
        if os.path.exists(self.local_location):
            launch = self.launch_test_local
            test_type = 'local'
        elif os.path.exists(self.installed_location):
            launch = self.launch_test_installed
            test_type = 'deb'
        else:
            launch = self.launch_test_click
            test_type = 'click'
        return launch, test_type

    def setUp(self):
        launch, self.test_type = self.setup_environment()
        self.home_dir = self._patch_home()
        self.pointing_device = Pointer(self.input_device_class.create())
        super(CalendarTestCase, self).setUp()

        #turn off the OSK so it doesn't block screen elements
        if model() != 'Desktop':
            os.system("stop maliit-server")
            self.addCleanup(os.system, "start maliit-server")

        # Unset the current locale to ensure locale-specific data
        # (day and month names, first day of the week, …) doesn’t get
        # in the way of test expectations.
        self.patch_environment('LC_ALL', 'C')

        launch()

    def launch_test_local(self):
        logger.debug("Running via local installation")
        self.app = self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.local_location,
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_installed(self):
        logger.debug("Running via installed debian package")
        self.app = self.launch_test_application(
            base.get_qmlscene_launch_command(),
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

        #click can use initctl env (upstart), but desktop still requires mock
        if self.test_type == 'click':
            environment.set_initctl_env_var('HOME', temp_dir)
            self.addCleanup(environment.unset_initctl_env_var, 'HOME')
        else:
            patcher = mock.patch.dict('os.environ', {'HOME': temp_dir})
            patcher.start()
            self.addCleanup(patcher.stop)

        logger.debug("Patched home to fake home directory " + temp_dir)
        return temp_dir

    @property
    def main_view(self):
        return self.app.wait_select_single(emulators.MainView)
