/*
    Copyright 2016-2024 Christian Loosli <develop@fuchsnet.ch>

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

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

MouseArea {

    property bool wasExpanded: false

    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    onPressed: mouse => {
        if (mouse.button == Qt.LeftButton) {
            wasExpanded = main.expanded;
        } else if (mouse.button == Qt.MiddleButton) {
            //TODO: Do something
        }
    }

    onClicked: mouse => {
        if (mouse.button == Qt.LeftButton) {
            main.expanded = !wasExpanded;
        }
    }

    onWheel: wheel => {
        const delta = (wheel.inverted ? -1 : 1) * (wheel.angleDelta.y ? wheel.angleDelta.y : -wheel.angleDelta.x);
        wheelDelta += delta;
        // Magic number 120 for common "one click"
        // See: https://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
        while (wheelDelta >= 120) {
            //TODO: Do something
        }
        while (wheelDelta <= -120) {
            //TODO: Do something
        }
    }

    Kirigami.Icon {
        anchors.fill: parent
        source: plasmoid.icon
    }
    
    property bool fullRepresentationInitialized: false

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
    
    //TODO: Unify with full rep
    /**
     * Helper to check the updated connection
     * @param {String} connection the connection state
     */
    function updatedConnection(connection, enforce) {

        if(connection === "none") {
            main.toolTipSubText = i18n("Hue bridge not reachable");
            plasmoid.status = PlasmaCore.Types.PassiveStatus;
            return;
        }
        else if(connection === "unauth") {
            plasmoid.toolTipSubText = i18n("Not authenticated with Hue bridge");
            main.status = PlasmaCore.Types.ActiveStatus;
            return;
        }
        else if(connection === "main") {
            main.toolTipSubText = i18n("Connected to Philips HUE via main connection");
            plasmoid.status = PlasmaCore.Types.ActiveStatus;
            getLights(lightModel)
            setLightsTooltip(i18n("Main connection"));
        }
        else if(connection === "alt") {
            main.toolTipSubText = i18n("Connected to Philips HUE via alternative connection");
            plasmoid.status = PlasmaCore.Types.ActiveStatus;
            getLights(lightModel)
            setLightsTooltip(i18n("Alternative connection"));
        
        }
    }

        /**
     * Helper to set a tooltip with baseText: n/m lights on
     * @param {String} baseText base text to use
     */
    function setLightsTooltip(baseText) {

        var myLights = lightModel;
        
        var lightsTotal = myLights.count;
        if (lightsTotal > 0) {
            var lightOn = 0;

            for(var i = 0; i < myLights.count; ++i) {
                if(myLights.get(i).von) {
                    lightOn++;
                }
            }

            var tooltip = baseText + ": " + lightOn + "/" + lightsTotal + " " + i18n("lights on")
            main.toolTipSubText = tooltip;
        }
    }

    Timer {
        id: compactTimer
    }
    
    ListModel {
        id: lightModel
    }  
}
