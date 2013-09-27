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

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from testtools.matchers import Equals

from ubuntuuitoolkit import emulators as toolkit_emulators
from calendar_app import emulators


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
    sqlite_dir = os.path.expanduser(
        "~/.local/share/Qt Project/QtQmlViewer/QML/OfflineStorage/Databases")
    backup_dir = sqlite_dir + ".backup"

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(CalendarTestCase, self).setUp()
        self.temp_move_sqlite_db()
        self.addCleanup(self.restore_sqlite_db)

        if os.path.exists(self.local_location):
            self.launch_test_local()
        elif os.path.exists(self.installed_location):
            self.launch_test_installed()
        else:
            self.launch_test_click()

    def launch_test_local(self):
        self.app = self.launch_test_application(
            "qmlscene",
            self.local_location,
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_installed(self):
        self.app = self.launch_test_application(
            "qmlscene",
            self.installed_location,
            "--desktop_file_hint=/usr/share/applications/"
            "calendar-app.desktop",
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_click(self):
        self.app = self.launch_click_package(
            "com.ubuntu.calendar-app",
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def temp_move_sqlite_db(self):
        if os.path.exists(self.backup_dir):
            shutil.rmtree(self.backup_dir)
        if os.path.exists(self.sqlite_dir):
            shutil.move(self.sqlite_dir, self.backup_dir)
            self.assertThat(
                lambda: os.path.exists(self.backup_dir),
                Eventually(Equals(True)))

    def restore_sqlite_db(self):
        if os.path.exists(self.backup_dir) and os.path.exists(self.sqlite_dir):
            shutil.rmtree(self.sqlite_dir)
            self.assertThat(
                lambda: os.path.exists(self.sqlite_dir),
                Eventually(Equals(False)))
            shutil.move(self.backup_dir, self.sqlite_dir)
            self.assertTrue(
                lambda: os.path.exists(self.sqlite_dir),
                Eventually(Equals(True)))
        elif os.path.exists(self.backup_dir):
            shutil.move(self.backup_dir, self.sqlite_dir)
            self.assertTrue(
                lambda: os.path.exists(self.sqlite_dir),
                Eventually(Equals(True)))
        else:
            pass

    @property
    def main_view(self):
        return self.app.select_single(emulators.MainView)
