/*
 *    Copyright 2016-2024 Christian Loosli <develop@fuchsnet.ch>
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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

PlasmaExtras.Representation {
        id: fullRep

        KeyNavigation.down: tabBar.currentItem


        header: PlasmaExtras.PlasmoidHeading {
            // Make this toolbar's buttons align vertically with the ones above
            rightPadding: -1
            // Allow tabbar to touch the header's bottom border
            bottomPadding: -bottomInset

            RowLayout {
                anchors.fill: parent
                spacing: Kirigami.Units.smallSpacing

                PC3.TabBar {
                    id: tabBar
                    Layout.fillWidth: true
                    Layout.fillHeight: true


                    // KeyNavigation.down: contentView.currentItem.contentItem.upperListView.itemAtIndex(0)

                    PC3.TabButton {
                        id: actionsTab
                        text: i18n("Actions")

                        KeyNavigation.up: fullRep.KeyNavigation.up
                    }

                    PC3.TabButton {
                        id: groupsTab
                        text: i18n("Groups")

                        KeyNavigation.up: fullRep.KeyNavigation.up
                    }

                    PC3.TabButton {
                        id: lightsTab
                        text: i18n("Lights")

                        KeyNavigation.up: fullRep.KeyNavigation.up
                    }
                }


                PC3.ToolButton {
                    visible: !(plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentDrawsPlasmoidHeading)

                    icon.name: "configure"
                    onClicked: plasmoid.internalAction("configure").trigger()

                    Accessible.name: plasmoid.internalAction("configure").text
                    PC3.ToolTip {
                        text: plasmoid.internalAction("configure").text
                    }
                }
            }
        }

        contentItem: StackView {
            id: contentView
            property var hiddenTypes: []
            initialItem: actionsView

            TwoPartView {
                id: actionsView
                listModel: actionModel
                listDelegate: ActionItem { }
                iconName: "edit-none"
                placeholderText: i18n("no actions")
            }

            TwoPartView {
                id: groupsView
                listModel: groupModel
                listDelegate: GroupItem { }
                iconName: "edit-none"
                placeholderText: i18n("no groups")
            }

            TwoPartView {
                id: lightsView
                listModel: lightModel
                listDelegate: LightItem { }
                iconName: "edit-none"
                placeholderText: i18n("no lights")
            }


            Connections {
                target: tabBar
                function onCurrentIndexChanged() {
                    if (tabBar.currentItem === actionsTab) {
                        contentView.replace(actionsView)
                    } else if (tabBar.currentItem === groupsTab) {
                        contentView.replace(groupsView)
                    } else if (tabBar.currentItem === lightsTab) {
                        contentView.replace(lightsView)
                    }
                }
            }
        }

        component TwoPartView : PC3.ScrollView {
            id: scrollView
            property string iconName: ""
            property string placeholderText: ""
            required property ListModel listModel
            required property Component listDelegate



            Loader {
                parent: scrollView
                anchors.centerIn: parent
                width: parent.width -  Kirigami.Units.gridUnit * 4
                active: visible
                visible: scrollView.listModel.length < 1
                sourceComponent: PlasmaExtras.PlaceholderMessage {
                    iconName: scrollView.iconName
                    text: scrollView.placeholderText
                }
            }
            contentItem: Flickable {
                contentHeight: layout.implicitHeight
                clip: true

                ColumnLayout {
                    id: layout
                    width: parent.width
                    spacing: 0
                    ListView {
                        id: content
                        visible: true
                        interactive: false
                        Layout.fillWidth: true
                        implicitHeight: contentHeight
                        model: scrollView.listModel
                        delegate: scrollView.listDelegate

                        Keys.onDownPressed: event => {
                            if (currentIndex < count - 1) {
                                incrementCurrentIndex();
                                currentItem.forceActiveFocus();
                            }
                            event.accepted = true;
                        }
                        Keys.onUpPressed: event => {
                            if (currentIndex > 0) {
                                decrementCurrentIndex();
                                currentItem.forceActiveFocus();
                            }
                            event.accepted = true;
                        }
                    }
                }
            }
        }

    Component.onCompleted: {
        getHueConfigured();
        reInit(true, true);
        resetTimer();
        compactRepresentationItem.fullRepresentationInitialized = true;
    }

    Connections {
        target: plasmoid.configuration

        onBaseURLChanged: {
            initHueConfig();
            checkHueConnection(updatedConnection, true);
        }
        
        onPollChanged: {
            resetTimer();
        }
        
        onPollTimeChanged: {
            resetTimer();
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
        // hueNotConfiguredView.visible = !getHueConfigured();
        // hueNotConnectedView.visible = getHueConfigured() && hueNotConnected;
        // tabView.visible = getHueConfigured() && !hueNotConnected;
        if(initial) {
            checkHueConnection(updatedConnection, true);
        }
        if(fetchAll) {
            //TODO busyOverlay.opacity = 1;
            getAll(groupModel, lightModel, fetchAllDone);
            addActions();
        }
    }
    
    // Method to restart the poll timer with configured values
    function resetTimer() {
        fullTimer.stop();
        if (plasmoid.configuration.poll) {
            // We store the time in seconds to be more user friendly
            fullTimer.interval = plasmoid.configuration.pollTime * 1000;
            fullTimer.repeat = true;
            fullTimer.triggered.connect(updateLoop);
            fullTimer.start();
        }
    }
    
    function fetchAllDone() {
        //TODO: busyOverlay.opacity = 0;
        // Done to initially set the tooltip
        checkHueConnection(updatedConnection, true);
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
            //TODO: hueNotConnected = true;
            //TODO: hueUnauthenticated = false;
            reInit(false, false);
            main.toolTipSubText = i18n("Hue bridge not reachable");
            plasmoid.status = PlasmaCore.Types.PassiveStatus;
            return;
        }
        else if(connection === "unauth") {
            //TODO: hueNotConnected = true;
            //TODO: hueUnauthenticated = true;
            reInit(false, false);
            main.toolTipSubText = i18n("Not authenticated with Hue bridge");
            plasmoid.status = PlasmaCore.Types.ActiveStatus;
            return;
        }
        else if(connection === "main") {
            //TODO: hueNotConnected = false;
            //TODO: hueUnauthenticated = false;
            reInit(false, false);
            setLightsTooltip(i18n("Main connection"));
            plasmoid.status = PlasmaCore.Types.ActiveStatus;
        }
        else if(connection === "alt") {
            //TODO: hueNotConnected = false;
            //TODO: hueUnauthenticated = false;
            reInit(false, false);
            setLightsTooltip(i18n("Alternative connection"));
            plasmoid.status = PlasmaCore.Types.ActiveStatus;
        }
    }
    
    /**
     * Helper to set a tooltip with baseText: n/m lights on
     * @param {String} baseText base text to use
     */
    function setLightsTooltip(baseText) {
        var myLights = lightModel

        var lightsTotal = myLights.count;
        var lightOn = 0;
  
        for(var i = 0; i < myLights.count; ++i) {
            if(myLights.get(i).von) {
                lightOn++;
            }
        }
        
        var tooltip = baseText + ": " + lightOn + "/" + lightsTotal + " " + i18n("lights on")
        main.toolTipSubText = tooltip;
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
            debugPrint("Failed to parse actionlist json: " + actionItems);
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
