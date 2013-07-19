# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot emulators."""


class MainWindow(object):
    """An emulator class that makes it easy to interact with the
    calendar-app.

    """
    def __init__(self, app):
        self.app = app

    def get_event_view(self):
        return self.app.select_single("EventView")

    def get_month_view(self):
        return self.app.select_single("MonthView")
