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
    
    property bool noHueConfigured: !Hue.getHueConfigured()
    property bool noHueConnected: false
    
    PlasmaComponents.TabBar {
        id: tabBar

        anchors {
            top: parent.top
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
        id: toolBar

        height: addDeviceButton.height
        anchors {
            top: tabBar.bottom
            topMargin: units.smallSpacing
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
                id: addDeviceButton
                iconSource: "list-add"
                tooltip: getAddTooltip()
                onClicked: {
                        addClicked()
                }
            }
            
            PlasmaComponents.ToolButton {
                id: refreshButton
                iconSource: "view-refresh"
                tooltip: i18n("Refresh")
                onClicked: {
                        refreshClicked()
                }
            }

            PlasmaComponents.ToolButton {
                id: openSettingsButton

                iconSource: "configure"
                tooltip: i18n("Configure Philips Hue...")

                onClicked: {
                    //TODO: Open configuration GUI
                }
            }
        }
    }
    
    Item {
        id: hueNotConfiguredView
        
        anchors {
            top: toolBar.bottom
            topMargin: units.smallSpacing
            left: parent.left
            right: parent.right
         }
        
        visible: noHueConfigured

        PlasmaExtras.Heading {
            id: noHueConfiguredHeading
            level: 3
            opacity: 0.6
            text: i18n("No Hue bridge configured")

            anchors {
                horizontalCenter: parent.horizontalCenterblu
                bottomMargin: units.smallSpacing
            }
        }

        //TODO: some text, maybe?
        
        PlasmaComponents.Button {
            id: configureHueBridgeButton
            text: i18n("Configure Hue Bridge")

            anchors {
                top: noHueConfiguredHeading.bottom
                topMargin: units.smallSpacing
            }

            onClicked: {
                //TODO: Implement me
            }
        }
    }
    
    Item {
        id: hueNotConnectedView
        
        anchors {
            top: tabBar.bottom
            topMargin: units.smallSpacing
            left: parent.left
            right: parent.right
         }
         
        visible: !noHueConfigured && noHueConnected

        PlasmaExtras.Heading {
            id: noHueConnectedHeading
            level: 3
            opacity: 0.6
            text: i18n("No Hue bridge connected")

            anchors {
                horizontalCenter: parent.horizontalCenterblu
                bottomMargin: units.smallSpacing
            }
        }

        //TODO: some text, maybe?
        
        PlasmaComponents.Button {
            id: connnectHueBridgeButton
            text: i18n("Configure Hue Bridge")

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: noHueConnectedHeading.bottom
                topMargin: units.smallSpacing
            }

            onClicked: {
                //TODO: Implement me
            }
        }
    }

    Item {
        id: tabView
        anchors {
            top: toolBar.bottom
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
    
    function reInit() {
        hueNotConfiguredView.visible = !Hue.getHueConfigured();
        hueNotConnectedView.visible = !Hue.getHueConfigured() && noHueConnected;
        tabView.visible = Hue.getHueConfigured();
        plasmoid.toolTipSubText = i18n("Connected: " + Hue.getHueConfigured());
    }

    function getAddTooltip() {
        if(tabBar.currentTab == actionsTab){
            return i18n("Add new action...")
        }
        else if(tabBar.currentTab == groupsTab){
            return i18n("Add new group or room ...")
        }
        else if(tabBar.currentTab == lightsTab){
            return i18n("Add new light ...")
        }
    }
    
    function addClicked() {
        if(tabBar.currentTab == actionsTab){
            //TODO: add action
        }
        else if(tabBar.currentTab == groupsTab){
            //TODO: add action
        }
        else if(tabBar.currentTab == lightsTab){
            //TODO: add action
        }
    }
    
    function refreshClicked() {
        reInit();
    }
    
    ListModel {
        id: actionModel
        ListElement {
            name: "Alle Lampen einschalten" 
            infoText: "SubText"
            icon: "im-jabber"
        }
        ListElement {
            name: "Alle Lampen ausschalten"
            infoText: "SubText"
            icon: "contrast"
        }
        ListElement {
            name: "Action 3" 
            infoText: "SubText"
        }
    }
    
    ListModel {
        id: groupModel
        ListElement {
            uuid: "1"
            name: "Wohnzimmer" 
            infoText: "2 Lampen"
            icon: "go-home"
        }
        ListElement {
            uuid: "2"
            name: "Büro" 
            infoText: "1 Lampe"
            icon: "mail-attchment"
        }
        ListElement {
            uuid: "3"
            name: "Küche" 
            infoText: "1 Lampe"
            icon: "view-filter"
        }
    }
    
    ListModel {
        id: lightModel
        ListElement {
            uuid: "1"
            name: "Wohnzimmer Decke"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Wohnzimmer Ball"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Schlafzimmer Decke"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Schlafzimmer Ball"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Flur vorne"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Flur hinten"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Küche Decke"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Büro Decke"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Gastzimmer Decke"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Mond"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
        ListElement {
            uuid: "1"
            name: "Sonne"
            infoText: "Extended color light"
            icon: "im-jabber"
        }
    }    
    
}
