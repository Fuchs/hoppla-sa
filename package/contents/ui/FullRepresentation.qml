/*
 *    Copyright 2016-2017 Christian Loosli <develop@fuchsnet.ch>
 * 
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Lesser General Public
 *    License as published by the Free Software Foundation; either
 *    version 2.1 of the License, or (at your option) version 3, or any
 *    later version accepted by the original Author.
 * 
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Lesser General Public License for more details.
 * 
 *    You should have received a copy of the GNU Lesser General Public
 *    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

FocusScope {
    focus: true
    id: mainView
    
    property bool noHueConfigured: !getHueConfigured()
    property bool hueNotConnected: false
    property bool hueUnauthenticated: false
    
    PlasmaComponents.BusyIndicator {
        id: busyOverlay
        anchors.centerIn: parent
        //whilst the model is loading, stay visible
        //we use opacity rather than visible to force an animation
        opacity: 0

        Behavior on opacity {
            PropertyAnimation {
                //this comes from PlasmaCore
                duration: units.shortDuration
            }
        }
    }
    
    Item {
        id: toolBar
        height: openSettingsButton.height
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        
        PlasmaCore.Svg {
            id: lineSvg
            imagePath: "widgets/line"
        }
        
        Row {
            id: rightButtons
            spacing: units.smallSpacing
            
            anchors {
                right: parent.right
                rightMargin: Math.round(units.gridUnit / 2)
                verticalCenter: parent.verticalCenter
            }
            
            PlasmaComponents.ToolButton {
                id: refreshButton
                iconSource: "view-refresh"
                tooltip: i18n("Refresh")
                onClicked: {
                    reInit(false, true);
                }
            }
            
            PlasmaComponents.ToolButton {
                id: openSettingsButton
                
                iconSource: "configure"
                tooltip: i18n("Configure Philips Hue...")
                
                onClicked: {
                    plasmoid.action("configure").trigger()
                }
            }
        }
    }
    
    PlasmaComponents.TabBar {
        id: tabBar
        
        anchors {
            top: toolBar.bottom
            left: parent.left
            right: parent.right
        }
        
        PlasmaComponents.TabButton {
            id: actionsTab
            text: i18n("Actions")
        }
        
        PlasmaComponents.TabButton {
            id: groupsTab
            text: i18n("Groups")
        }
        
        PlasmaComponents.TabButton {
            id: lightsTab
            text: i18n("Lights")
        }
    }
    
    
    Item {
        id: hueNotConfiguredView
        
        anchors.fill: parent
        visible: noHueConfigured
        
        PlasmaExtras.Heading {
            id: noHueConfiguredHeading
            level: 3
            opacity: 0.6
            text: i18n("No Hue bridge configured")
            
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: noHueConfiguredLabel.top
                bottomMargin: units.smallSpacing
            }
        }
        
        PlasmaComponents.Label {
            id: noHueConfiguredLabel
            
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: configureHueBridgeButton.top
                bottomMargin: units.largeSpacing
            }
            
            height: paintedHeight
            elide: Text.ElideRight
            font.weight: Font.Normal
            font.pointSize: theme.smallestFont.pointSize
            text : i18n("You need to configure your Hue bridge")
            textFormat: Text.PlainText
        }
        
        PlasmaComponents.Button {
            id: configureHueBridgeButton
            text: i18n("Configure Hue Bridge")
            
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            
            onClicked: {
                plasmoid.action("configure").trigger()
            }
        }
    }
    
    Item {
        id: hueNotConnectedView
        
        anchors.fill: parent
        visible: false
        
        PlasmaExtras.Heading {
            id: hueNotConnectedHeading
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: hueNotConnectedLabel.top
                bottomMargin: units.smallSpacing
            }
            
            level: 3
            opacity: 0.6
            text: hueUnauthenticated ?  i18n("Not authenticated") : i18n("Hue not reachable")
        }
        
        PlasmaComponents.Label {
            id: hueNotConnectedLabel
            
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: connnectHueBridgeButton.top
                bottomMargin: units.largeSpacing
            }
            
            font.weight: Font.Normal
            height: paintedHeight
            elide: Text.ElideRight
            font.pointSize: theme.smallestFont.pointSize
            text : hueUnauthenticated ? i18n("Authenticate with your bridge") : i18n("Check if your Hue bridge is configured and reachable") 
            textFormat: Text.PlainText
        }
        
        PlasmaComponents.Button {
            id: connnectHueBridgeButton
            text: i18n("Configure Hue Bridge")
            
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            
            onClicked: {
                plasmoid.action("configure").trigger()
            }
        }
    }
    
    Item {
        id: tabView
        anchors {
            top: tabBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        
        
        PlasmaExtras.ScrollArea {
            id: actionScrollView
            visible: tabBar.currentTab == actionsTab && !noHueConfigured && !hueNotConnected && !hueUnauthenticated
            
            anchors {
                top: parent.top
                topMargin: units.smallSpacing
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            
            ListView {
                id: actionView
                anchors.fill: parent
                clip: true
                currentIndex: -1
                model: actionModel
                boundsBehavior: Flickable.StopAtBounds
                delegate: ActionItem { }
            }
        }
        
        PlasmaExtras.ScrollArea {
            id: groupScrollView
            visible: tabBar.currentTab == groupsTab && !noHueConfigured && !hueNotConnected
            
            anchors {
                top: parent.top
                topMargin: units.smallSpacing
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            
            ListView {
                id: groupView
                anchors.fill: parent
                clip: true
                currentIndex: -1
                boundsBehavior: Flickable.StopAtBounds
                model: groupModel
                delegate: GroupItem { }
            }
        }
        
        PlasmaExtras.ScrollArea {
            id: lightScrollView
            visible: tabBar.currentTab == lightsTab && !noHueConfigured && !hueNotConnected
            
            anchors {
                top: parent.top
                topMargin: units.smallSpacing
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            
            ListView {
                id: lightsView
                anchors.fill: parent
                clip: true
                currentIndex: -1
                boundsBehavior: Flickable.StopAtBounds
                model: lightModel
                delegate: LightItem { }
            }
        }
    }
    
    Component.onCompleted: {
        initHueConfig();
        reInit(true, true);
        fullTimer.stop();
        // Check connection every 30 seconds
        fullTimer.interval = 30000;
        fullTimer.repeat = true;
        fullTimer.triggered.connect(updateLoop);
        fullTimer.start();
    }
    
    Connections {
        target: plasmoid.configuration

        onBaseURLChanged: {
            initHueConfig();
            checkHueConnection(updatedConnection, true);
        }
        
        onAuthTokenChanged: {
            initHueConfig();
            checkHueConnection(updatedConnection, true);
        }
        
        onActionlistChanged: {
            addActions();
        }
    }
    
    // Method to re-init the plasmoid. 
    // This is used on refresh because it puts way less load on the Hue bridge
    // as it fetches all lights and groups together, instead of updating each.
    // This leads to side effects such as closing the current expanded selection, 
    // but this should be acceptable, else updateGroups and updateLights can be used.
    function reInit(initial, fetchAll) {
        //TODO: add a nice overlay while loading
        hueNotConfiguredView.visible = !getHueConfigured();
        hueNotConnectedView.visible = getHueConfigured() && hueNotConnected;
        tabView.visible = getHueConfigured() && !hueNotConnected;
        if(initial) {
            checkHueConnection(updatedConnection, true);
        }
        if(fetchAll) {
            busyOverlay.opacity = 1;
            getAll(groupModel, lightModel, fetchAllDone);
            addActions();
        }
    }
    
    function fetchAllDone() {
        busyOverlay.opacity = 0;
    }
    
    /**
     * Helper function executed periodically.
     * Checks the connection and, if the plasmoid is not expanded
     * and there is a connection to the main or alt bridge,
     * updates all items
     */
    function updateLoop() {
        // Check connection state
        checkHueConnection(updatedConnection, false);
    }
    
    /**
     * Helper to check the updated connection
     * @param {String} connection the connection state
     * @param {bool} enforce update shall be enforced despite expanded plasmoid
     */
    function updatedConnection(connection, enforce) {
        if(plasmoid.expanded && !enforce) {
            // Don't interrupt the user
            return;
        }
        
        if(connection === "none") {
            hueNotConnected = true;
            hueUnauthenticated = false;
            reInit(false, false);
            plasmoid.toolTipSubText = i18n("Hue bridge not reachable");
            return;
        }
        else if(connection === "unauth") {
            hueNotConnected = true;
            hueUnauthenticated = true;
            reInit(false, false);
            plasmoid.toolTipSubText = i18n("Not authenticated with Hue bridge");
            return;
        }
        else if(connection === "main") {
            hueNotConnected = false;
            hueUnauthenticated = false;
            reInit(false, false);
            setLightsTooltip(i18n("Main connection"));
        }
        else if(connection === "alt") {
            hueNotConnected = false;
            hueUnauthenticated = false;
            reInit(false, false);
            setLightsTooltip(i18n("Alternative connection"));
        }
    }
    
    /**
     * Helper to set a tooltip with baseText: n/m lights on
     * @param {String} baseText base text to use
     */
    function setLightsTooltip(baseText) {

        var lightsTotal = lightModel.count;
        var lightOn = 0;
  
        for(var i = 0; i < lightModel.count; ++i) {
            if(lightModel.get(i).von) {
                lightOn++;
            }
        }
        
        var tooltip = baseText + ": " + lightOn + "/" + lightsTotal + " " + i18n("lights on")
        plasmoid.toolTipSubText = tooltip;
    }
    
    /**
     * Helper to add initial actions, later on also configured ones
     */
    function addActions() {
        actionModel.clear();
        
        try {
            var actionItems = JSON.parse(plasmoid.configuration.actionlist);
        }
        catch(e) {
            debugPrint("Failed to parse actionlist json: " + json);
            return;
        }
        
        for(var uuid in actionItems) {
            var cItem = actionItems[uuid];
            var actionItem = {};
            actionItem.uuid = uuid;
            actionItem.userAdded = cItem.userAdded;
            actionItem.title = cItem.userAdded ? cItem.title : i18n(cItem.title);
            actionItem.subtitle = cItem.userAdded ? cItem.subtitle : i18n(cItem.subtitle);
            actionItem.icon = cItem.icon;
            actionItem.actions = cItem.actions;
            
            actionModel.append(actionItem);
        }
    }
    
    
    ListModel {
        id: actionModel
    }
    
    ListModel {
        id: groupModel
    }
    
    ListModel {
        id: lightModel
    }  
    
    Timer {
        id: fullTimer
    }
}
