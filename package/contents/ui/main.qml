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
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

import "logic.js" as Logic
import "hue.js" as Hue

Item {
    id: hopplaApplet
    property bool debug: true
    
    Plasmoid.toolTipMainText: i18n("Philips Hue lights")
    Plasmoid.icon: Logic.icon()
    
    Plasmoid.compactRepresentation: CompactRepresentation { }
    Plasmoid.fullRepresentation: FullRepresentation { }
    


    function debugPrint(msg) {
        if(!debug) {
            return;
        }
        print('[Hoppla] ' + msg)
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
    
    function updateGroup(group) {
        Hue.updateGroup(group);
    }
    
    function updateLight(light) {
        Hue.updateLight(light);
    }
    
    // Apparently plasmoid is not available everywhere ...
    function isPlasmoidExpanded() {
        return plasmoid.expanded;
    }

}
