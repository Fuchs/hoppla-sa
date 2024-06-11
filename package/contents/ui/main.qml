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
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

import org.kde.kcmutils as KCMUtils
import org.kde.config as KConfig

import "code/hue.js" as Hue

PlasmoidItem {
    id: main

    property string displayName: "Hoppla Hue Plasmoid"

    switchHeight: Layout.minimumHeight
    switchWidth: Layout.minimumWidth

    Plasmoid.icon: "im-jabber"

    toolTipMainText: {
        return i18n("Hoppla Hue Plasmoid");
    }

    fullRepresentation: FullRepresentation { }

    compactRepresentation: CompactRepresentation { }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Refresh")
            icon.name: "view-refresh"
            onTriggered: {
                fullRepresentationItem.reInit(false, true)
            }
        }
    ]

    Component.onCompleted: {
        // We need to init here, otherwise there is a strange plasma bug
        // which can lead to plasmoid.configuration being unavailable,
        // thus the plasmoid failing badly.

        initHueConfig();
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
    
    function action_refresh() {
       fullRepresentationItem.reInit(false, true);
    }


    function debugPrint(msg) {
        Hue.debugPrint(msg)
    }
    
    function initHueConfig() {
        Hue.initHueConfig();
    }
    
    function getHueConfigured() {
        return Hue.getHueConfigured();
    }
    
    function checkHueConnection(callback, enforce) {
        Hue.checkHueConnection(callback, enforce);
    }
    
    function getAll(groupModel, lightModel, guiFinishedCallback) {
        Hue.getAll(groupModel, lightModel, guiFinishedCallback);
    }
    
    function getGroups(model) {
        Hue.getGroups(model);
    }
    
    function getLights(model) {
        Hue.getLights(model);
    }
    
    function getGroupLights(groupLightModel, slights) {
         Hue.getGroupLights(groupLightModel, slights);
    }
    
    function setGroupBrightness(vuuid, value) {
        Hue.setGroupBrightness(vuuid, value);
    }
    
    function setLightBrightess(vuuid, value) {
        Hue.setLightBrightess(vuuid, value);
    }
    
    function setGroupColourTemp(vuuid, ct) {
        Hue.setGroupColourTemp(vuuid, ct);
    }
    
    function setLightColourTemp(vuuid, ct) {
        Hue.setLightColourTemp(vuuid, ct);
    }
    
    function setGroupColourHS(vuuid, hue, sat) {
        Hue.setGroupColourHS(vuuid, hue, sat);
    }
    
    function setLightColourHS(vuuid, hue, sat) {
        Hue.setLightColourHS(vuuid, hue, sat);
    }
    
    function switchGroup(vuuid, val) {
        Hue.switchGroup(vuuid, val);
    }
    
    function switchLight(vuuid, val) {
          Hue.switchLight(vuuid, val);
    }
    
    function updateGroup(group, delay) {
        Hue.updateGroup(group, delay);
    }
    
    function updateLight(light, delay) {
        Hue.updateLight(light, delay);
    }
}
