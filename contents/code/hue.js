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

var base = plasmoid.configuration.baseURL 
var auth = plasmoid.configuration.authToken
var url = "http://" + base + "/api/" + auth + "/" 

// GETTERS

function getHueConfigured() {
    return isEmpty(base);
}

function getHueConnection() {
}

function getLights() {
}

function getLight(lightId) {
}

function getGroups() {
}

function getGroup(groupId) {
}

function getLightsForGroup(groupId) {
}

// SWITCH

function switchLight(lightId, on) {
}

function switchGroup(groupId, on) {
}

// GROUP SETTER

function setGroupBrightness(groupId, brightness) {
}


// LIGHT SETTER

function setLightBrightess(lightId, brighness) {
}

// HELPERS 

function isEmpty(str) {
    if(str)
    {
        toTest = str.trim;
        return  0 === toTest.length;
    }
    else
    {
        return true;
    }
}



