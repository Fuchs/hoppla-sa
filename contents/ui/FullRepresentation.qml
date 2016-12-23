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
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

import "../code/hue.js" as Hue

FocusScope {
    focus: true
    id: mainView
    
    property bool noHueConfigured: !Hue.getHueConfigured()
    property bool noHueConnected: false
    
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
                    reInit();
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
            text: i18n("Groups / Rooms")
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
        visible: !noHueConfigured && noHueConnected

        PlasmaExtras.Heading {
            id: noHueConnectedHeading
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: noHueConnectedLabel.top
                bottomMargin: units.smallSpacing
            }
            
            level: 3
            opacity: 0.6
            text: i18n("No Hue bridge connected")
        }

        PlasmaComponents.Label {
            id: noHueConnectedLabel

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: connnectHueBridgeButton.top
                bottomMargin: units.largeSpacing
            }

            font.weight: Font.Normal
            height: paintedHeight
            elide: Text.ElideRight
            font.pointSize: theme.smallestFont.pointSize
            text : i18n("Check if your Hue bridge is configured and reachable")
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
            visible: tabBar.currentTab == actionsTab && !noHueConfigured && !noHueConnected
            
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
            visible: tabBar.currentTab == groupsTab && !noHueConfigured && !noHueConnected
            
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
            visible: tabBar.currentTab == lightsTab && !noHueConfigured && !noHueConnected
            
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
        reInit();
    }
    
    function reInit() {
        hueNotConfiguredView.visible = !Hue.getHueConfigured();
        hueNotConnectedView.visible = !Hue.getHueConfigured() && noHueConnected;
        tabView.visible = Hue.getHueConfigured();
        plasmoid.toolTipSubText = i18n("Connected: " + Hue.getHueConfigured());
        groupModel.clear();
        Hue.getGroups(groupModel);
        lightModel.clear();
        Hue.getLights(lightModel);
    }

    
    ListModel {
        id: actionModel
        ListElement {
            name: "Alle Lampen einschalten" 
            infoText: "Schaltet alle Lampen ein"
            icon: "im-jabber"
            action: "allon"
        }
        ListElement {
            name: "Alle Lampen ausschalten"
            infoText: "Schaltet alle Lampen aus"
            icon: "contrast"
            action: "alloff"
        }
    }
    
    ListModel {
        id: groupModel
    }
    
    ListModel {
        id: lightModel
    }  
}
