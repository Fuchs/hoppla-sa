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
var groups;

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

function getLights(myModel) {
    var myUrl = url + "lights";
    getJsonFromHue(myUrl, parseLights, baseFail, myModel, "");
}

function getLight(myModel, lightId) {
    var myUrl = url + "lights/" + lightId;
    getJsonFromHue(myUrl, parseLight, baseFail, myModel, lightId);
}groupLightModel

function getGroups(myModel) {
    var myUrl = url + "groups";
    getJsonFromHue(myUrl, parseGroups, baseFail, myModel, "");
}

function getGroupLights(myModel, slights) {
    if(slights) {
        var array = slights.split(',');
        for(var index = 0; index < array.length; ++index) {
            getLight(myModel, array[index]);
        }
    }
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

function getJsonFromHue(getUrl, successCallback, failCallback, container, name) {
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
        successCallback(json, container, name);
    }
    request.open('GET', getUrl);
    request.send();
}

function putJsonToHue(putUrl, payload, successCallback, failCallback, name) {
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
        
        successCallback(json, name);
    }
    request.open('PUT', putUrl);
    request.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    request.send(payload);
    debugPrint('PUT called for url: ' + putUrl)
}

function baseSuccess() {
    debugPrint('success callback called');
}

function baseFail () {
    debugPrint('fail callback called');
}

function parseGroups(json, listModel, name) {
    var myGroups = JSON.parse(json);
    
    for(var groupName in myGroups) {
        var cgroup = myGroups[groupName];
        var myGroup = {
            vuuid: groupName,
            vname: cgroup.name,
            vtype: cgroup.type,
            vlights: cgroup.lights,
            slights: "" + cgroup.lights,
            vall_on: cgroup.state.all_on,
            vany_on: cgroup.state.all_on,
            vclass: cgroup.class,
            von: cgroup.action.on,
            vbri: cgroup.action.bri,
            vhue: cgroup.action.hue,
            vsat: cgroup.action.sat,
            veffect: cgroup.action.effect,
            vx: cgroup.action.xy[0],
            vy: cgroup.action.xy[1],
            vct: cgroup.action.ct,
            valert: cgroup.action.alert,
            vcolormode: cgroup.action.colormode,
            vicon: "go-home"
        };
        
        listModel.append(myGroup);
    }
}



function parseLights(json, listModel, name) {
    var myLights = JSON.parse(json);
    for(var lightName in myLights) {
        var clight = myLights[lightName];
        var myLight = {
            vuuid: lightName,
            vname: clight.name,
            von: clight.state.on,
            vbri: clight.state.bri,
            vhue: clight.state.hue,
            vsat: clight.state.sat,
            veffect: clight.state.effect,
            vx: clight.state.xy[0],
            vy: clight.state.xy[1],
            vct: clight.state.ct,
            valert: clight.state.alert,
            vcolormode: clight.state.colormode,
            vreachable: clight.state.reachable,
            vtype: clight.type,
            vmanufacturername: clight.manufacturername,
            vmodelid: clight.modelid,
            vuniqueid: clight.uniqueid,
            vswversion: clight.swversion,
            vswconfigid: clight.swconfigid,
            vproductid: clight.productid,
            vicon: "go-home"
        };
        listModel.append(myLight);
    }
}

function parseLight(json, listModel, lightName) {
    var clight = JSON.parse(json);
    var myLight = {
        vuuid: lightName,
        vname: clight.name,
        von: clight.state.on,
        vbri: clight.state.bri,
        vhue: clight.state.hue,
        vsat: clight.state.sat,
        veffect: clight.state.effect,
        vx: clight.state.xy[0],
        vy: clight.state.xy[1],
        vct: clight.state.ct,
        valert: clight.state.alert,
        vcolormode: clight.state.colormode,
        vreachable: clight.state.reachable,
        vtype: clight.type,
        vmanufacturername: clight.manufacturername,
        vmodelid: clight.modelid,
        vuniqueid: clight.uniqueid,
        vswversion: clight.swversion,
        vswconfigid: clight.swconfigid,
        vproductid: clight.productid,
        vicon: "go-home"
    };
    listModel.append(myLight);
    
}
