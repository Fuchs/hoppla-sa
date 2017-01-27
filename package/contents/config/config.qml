/*
    Copyright 2016-2017 Christian Loosli <develop@fuchsnet.ch>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the original Author.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

import org.kde.plasma.configuration 2.0

ConfigModel {
    id: configModel

    ConfigCategory {
         name: i18n("Bridge")
         icon: "applications-other"
         source: "configBridge.qml"
    }
    ConfigCategory {
         name: i18n("Actions")
         icon: "run-build"
         source: "configActions.qml"
     }
    ConfigCategory {
        name: i18n("Lights")
        icon: "im-jabber"
        source: "configLights.qml"
    }
    ConfigCategory {
        name: i18n("Groups")
        icon: "view-group"
        source: "configGroups.qml"
    }
    ConfigCategory {
        name: i18n("Schedules")
        icon: "clock"
        source: "configSchedules.qml"
    }
}
