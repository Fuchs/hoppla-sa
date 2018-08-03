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

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
    onClicked: plasmoid.expanded = !plasmoid.expanded
    property bool fullRepresentationInitialized: false

    PlasmaCore.IconItem {
        id: hopplaslIcon
        anchors.fill: parent
        source: "im-jabber"
    }

    Component.onCompleted: {
        getHueConfigured();
        resetTimer();
    }
    
        Connections {
        target: plasmoid.configuration

        onPollChanged: {
            resetTimer();
        }
        
        onPollTimeChanged: {
            resetTimer();
        }
    }
    
    // Method to restart the poll timer with configured values
    function resetTimer() {
        compactTimer.stop();
        if (plasmoid.configuration.poll && !fullRepresentationInitialized) {
            // We store the time in seconds to be more user friendly
            compactTimer.interval = plasmoid.configuration.pollTime * 1000;
            compactTimer.repeat = true;
            compactTimer.triggered.connect(updateLoop);
            compactTimer.start();
        }
    }
    
    /**
     * Helper function executed periodically.
     * Checks the connection and if  there is a connection to
     * the main or alt bridge.
     */
    function updateLoop() {
        if (!fullRepresentationInitialized) {
            // Check connection state
            checkHueConnection(updatedConnection, false);
        }
        else {
            resetTimer();
        }
    }
    
    /**
     * Helper to check the updated connection
     * @param {String} connection the connection state
     */
    function updatedConnection(connection, enforce) {

        if(connection === "none") {
            plasmoid.toolTipSubText = i18n("Hue bridge not reachable");
            plasmoid.status = PlasmaCore.Types.PassiveStatus;
            return;
        }
        else if(connection === "unauth") {
            plasmoid.toolTipSubText = i18n("Not authenticated with Hue bridge");
            plasmoid.status = PlasmaCore.Types.ActiveStatus;
            return;
        }
        else if(connection === "main") {
            plasmoid.toolTipSubText = i18n("Connected to Philips HUE via main connection");
            plasmoid.status = PlasmaCore.Types.ActiveStatus;
        }
        else if(connection === "alt") {
            plasmoid.toolTipSubText = i18n("Connected to Philips HUE via alternative connection");
            plasmoid.status = PlasmaCore.Types.ActiveStatus;
        }
    }
    
    Timer {
        id: compactTimer
    }
}
