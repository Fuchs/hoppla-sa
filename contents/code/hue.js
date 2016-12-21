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
    reloadConfig()
    if (!base.trim()) {
        // is empty or whitespace
        return false;
    }
    return true;
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
    var body = on ? '{"on":true}' : '{"on":false}';
    var myUrl = url + "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

function switchGroup(groupId, on) {
    var body = on ? '{"on":true}' : '{"on":false}';
    var myUrl = url + "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

// GROUP SETTER

function setGroupBrightness(groupId, brightness) {
    var body = '{"bri":' + brightness + '}';
    var myUrl = url + "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}


// LIGHT SETTER

function setLightBrightess(lightId, brightness) {
    var body = '{"bri":' + brightness + '}';
    var myUrl = url + "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

// HELPERS 

function reloadConfig() {
    base = plasmoid.configuration.baseURL 
    auth = plasmoid.configuration.authToken
    url = "http://" + base + "/api/" + auth + "/" 
}

function fetchJsonFromHue(getUrl, successCallback, failCallback) {
    var request = new XMLHttpRequest();
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        
        if (request.status !== 200) {
            failureCallback();
            return;
        }

        var json = request.responseText;
        successCallback(json);
    }
    request.open('GET', getUrl);
    request.send();
}

function putJsonToHue(putUrl, payload, successCallback, failCallback) {
    var request = new XMLHttpRequest();
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        
        if (request.status !== 200) {
            debugPrint('ERROR - status: ' + request.status)
            debugPrint('ERROR - responseText: ' + request.responseText)
            failureCallback();
            return;
        }

        debugPrint('successfull call to: ' + putUrl)
        var json = request.responseText;
        debugPrint('result: ' + json);
        
        successCallback(json);
    }
    request.open('PUT', putUrl);
    request.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    request.send(payload);
    debugPrint('PUT called for url: ' + putUrl)
}

function baseSuccess() {
}

function baseFail () {
}




