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

//TODO: This seems to not work when being called from the config UI, find out why and fix


// GETTERS

function getHueConfigured() {
    var base = plasmoid.configuration.baseURL 
    if (!base.trim()) {
        // is empty or whitespace
        return false;
    }
    return true;
}

function getLights(myModel) {
    var myUrl = "lights";
    getJsonFromHue(myUrl, parseLightsToModel, baseFail, myModel, "");
}

function getLight(myModel, lightId) {
    var myUrl = "lights/" + lightId;
    getJsonFromHue(myUrl, parseLightToModel, baseFail, myModel, lightId);
}

function updateLight(myLight) {
    var myUrl = "lights/" + myLight.vuuid;
    getJsonFromHue(myUrl, parseLightToObject, baseFail, myLight, myLight.vuuid);
}

function getGroups(myModel) {
    var myUrl = "groups";
    getJsonFromHue(myUrl, parseGroupsToModel, baseFail, myModel, "");
}

function getGroupLights(myList, myLights) {
    if(myLights) {
        myList.clear();
        var array = myLights.split(',');
        for(var index = 0; index < array.length; ++index) {
            getLight(myList, array[index]);
        }
    }
}

function updateGroup(myGroup) {
    var myUrl = "groups/" + myGroup.vuuid;
    getJsonFromHue(myUrl, parseGroupToObject, baseFail, myGroup, myGroup.vuuid);
}

// SWITCH

function switchLight(lightId, on) {
    var body = on ? '{"on":true}' : '{"on":false}';
    var myUrl = "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

function switchGroup(groupId, on) {
    var body = on ? '{"on":true}' : '{"on":false}';
    var myUrl = "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

// GROUP SETTER

function setGroupBrightness(groupId, brightness) {
    var body = '{"bri":' + brightness + '}';
    var myUrl = "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

function setGroupColourTemp(groupId, ct) {
    var body = '{"ct":' + ct + ',"colormode": "ct"}';
    var myUrl = "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

function setGroupColourHS(groupId, hue, sat) {
    var body = '{"hue":' + hue + ',"sat":' + sat + ',"colormode": "hs"}';
    var myUrl = "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

// LIGHT SETTER

function setLightBrightess(lightId, brightness) {
    var body = '{"bri":' + brightness + '}';
    var myUrl = "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

function setLightColourTemp(lightId, ct) {
    var body = '{"ct":' + ct + '}';
    var myUrl = "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

function setLightColourHS(lightId, hue, sat) {
    var body = '{"hue":' + hue + ',"sat":' + sat + '}';
    var myUrl = "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

// Authenticate

function authenticateWithBridge(bridgeUrl, hostname, sCb, fCb) {
    var appname = "Hoppla-SA";
    // https://www.developers.meethue.com/documentation/configuration-api#71_create_user
    var maxLength = 19; 
    
    if (!hostname) {
        hostname = "unknowndevice"
    }
    else {
        if(hostname.length > maxLength) {
            hostname = hostname.substring(0, maxLength);
        }
    }
    var body =  '{"devicetype":"' + appname + '#' + hostname + '"}'
    var attempt = 1; 
    var attempts = 12;
    var postUrl = bridgeUrl + "/api";
    postJsonToHue(postUrl, body, attempt, attempts, authSuccess, authFail, sCb, fCb)
}


function authFail(postUrl, body, att, maxAtt, request, gSuccCb, gFailCb) {
    var attempt = ++att;
    var mytimer = new Timer();
    mytimer.interval = 5000;
    mytimer.repeat = false;
    mytimer.triggered.connect(function () {
        postJsonToHue(postUrl, body, attempt, maxAtt, authSuccess, authFail, gSuccCb, gFailCb)
    })
    mytimer.start();
    gFailCb("unknown error");
}

function authSuccess(json, postUrl, body, att, maxAtt, request, gSuccCb, gFailCb) {
    if(!json) {
        return;
    }
    var myResult = JSON.parse(json);
    if(!myResult[0]) {
        return;
    }
    
    if(myResult[0].error) {
        if(myResult[0].error.type == 101) {
            var attempt = ++att;
            var mytimer = new Timer();
            mytimer.interval = 5000;
            mytimer.repeat = false;
            mytimer.triggered.connect(function () {
                postJsonToHue(postUrl, body, attempt, maxAtt, authSuccess, authFail, gSuccCb, gFailCb)
            })
            mytimer.start();
            gFailCb(myResult[0].error.description);
            return;
        }
    }
    else if(myResult[0].success) {
        gSuccCb(myResult[0].success.username);
        return;
    }
    
    var attempt = ++att;
    var mytimer = new Timer();
    mytimer.interval = 5000;
    mytimer.repeat = false;
    mytimer.triggered.connect(function () {
        postJsonToHue(postUrl, body, attempt, maxAtt, authSuccess, authFail, gSuccCb, gFailCb)
    })
    mytimer.start();
    gFailCb("unknown error");
    
}

// HELPERS 

function getBaseUrlRequest(pUrl, pType) {
    var base = plasmoid.configuration.baseURL 
    var auth = plasmoid.configuration.authToken
    var url = base + "/api/" + auth + "/" + pUrl
    var request = new XMLHttpRequest();
    request.timeout = 2000;
    if(!plasmoid.configuration.useAuth) {
        request.open(pType, url);
    }
    else {
        request.open(pType, url, true, plasmoid.configuration.username, plasmoid.configuration.password);
    }
    return request;
}

function getAltUrlRequest(pUrl, pType) {
    var base = plasmoid.configuration.altURL
    var auth = plasmoid.configuration.authToken
    var url = base + "/api/" + auth + "/" + pUrl
    var request = new XMLHttpRequest();
    request.timeout = 5000;
    if(!plasmoid.configuration.altUseAuth) {
        debugPrint("Not using authentication");
        request.open(pType, url);
    }
    else {
        debugPrint("Using authentication");
        request.open(pType, url, true, plasmoid.configuration.altUsername, plasmoid.configuration.altPassword);
    }
    return request;
}

function getJsonFromHue(getUrl, successCallback, failureCallback, object, name) {
    var request = getBaseUrlRequest(getUrl, 'GET');
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        
        if (request.status !== 200) {
            if(plasmoid.configuration.useAltURL) {
                debugPrint("Request to " + getUrl + " failed, trying alt URL")
                var altRequest = getAltUrlRequest(getUrl, 'GET');
                altRequest.onreadystatechange = function () {
                    if (altRequest.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }
                    if (altRequest.status !== 200) {
                        debugPrint("Request to " + getUrl + " failed with alt URL as well")
                        failureCallback(altRequest);
                    }
                    
                    var json = altRequest.responseText;
                    successCallback(json, object, name);
                }
                altRequest.send();
            }
            else {
                debugPrint("Request to " + getUrl + " failed, no alt Url specified")
                failureCallback(request);
            }
        }
        var json = request.responseText;
        successCallback(json, object, name);
    }
    request.send();
}

function putJsonToHue(putUrl, payload, successCallback, failureCallback) {
    var request = getBaseUrlRequest(putUrl, 'PUT');
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        if (request.status !== 200) {
            if(plasmoid.configuration.useAltURL) {
                debugPrint("Request to " + putUrl + " failed, trying alt URL")
                var altRequest = getAltUrlRequest(putUrl, 'PUT');
                altRequest.onreadystatechange = function () {
                    if (altRequest.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }
                    
                    if (altRequest.status !== 200) {
                        debugPrint("Request to " + putUrl + " failed with alt URL as well")
                        failureCallback(altRequest);
                    }
                    
                    var json = altRequest.responseText;
                    successCallback(json, name);
                }
                altRequest.send();
            }
            else {
                debugPrint("Request to " + putUrl + " failed, no alt Url specified")
                failureCallback(request);
            }
        }

            var json = request.responseText;
            successCallback(json);
    }
    request.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    request.send(payload);
}

function postJsonToHue(postUrl, body, att, maxAtt, lSuccCb, lFailCb, gSuccCb, gFailCb) {
    if(att > maxAtt) {
        return;
    }
    var request = new XMLHttpRequest();
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        
        if (request.status !== 200) {
            lFailCb(postUrl, body, att, maxAtt, request, gSuccCb, gFailCb);
            return;
        }
        
        var json = request.responseText;
        lSuccCb(json, postUrl, body, att, maxAtt, request, gSuccCb, gFailCb);
    }
    request.open('POST', postUrl);
    request.send(body);
}

function baseSuccess(json, name) {
    
}

function baseFail (request) {
    debugPrint("Communicating with hue failed");
    if(request.status) {
        debugPrint("Status: " + request.status);
    }
    if(request.responseText) {
        debugPrint("Response: " + request.responseText);
    }
}

function parseGroupsToModel(json, listModel, name) {
    var myGroups = JSON.parse(json);
    listModel.clear();
    for(var groupName in myGroups) {
        var cgroup = myGroups[groupName];
        var myGroup = {
            vuuid: groupName,
            vname: cgroup.name,
            vtype: cgroup.type,
            vlights: cgroup.lights,
            slights: "" + cgroup.lights,
            vall_on: cgroup.state.all_on,
            vany_on: cgroup.state.any_on,
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
            vLastUpdated: getCurrentTime()
        };
        
        listModel.append(myGroup);
    }
}

function parseGroupToObject(json, myObject, name) {
    var cgroup = JSON.parse(json);
    myObject.vuuid = name;
    myObject.vname = cgroup.name;
    myObject.vtype = cgroup.type;
    myObject.vlights = cgroup.lights;
    myObject.slights = "" + cgroup.lights;
    myObject.vall_on = cgroup.state.all_on;
    myObject.vany_on = cgroup.state.any_on;
    myObject.vclass = cgroup.class;
    myObject.von = cgroup.action.on;
    myObject.vbri = cgroup.action.bri;
    myObject.vhue = cgroup.action.hue;
    myObject.vsat = cgroup.action.sat;
    myObject.veffect = cgroup.action.effect;
    myObject.vx = cgroup.action.xy[0];
    myObject.vy = cgroup.action.xy[1];
    myObject.vct = cgroup.action.ct;
    myObject.valert = cgroup.action.alert;
    myObject.vcolormode = cgroup.action.colormode;
    myObject.vLastUpdated = getCurrentTime();
}

function parseLightsToModel(json, listModel, name) {
    var myLights = JSON.parse(json);
    listModel.clear();
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
            vLastUpdated: getCurrentTime()
        };
        listModel.append(myLight);
    }
}

function parseLightToModel(json, listModel, lightName) {
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
        vLastUpdated: getCurrentTime()
    };
    listModel.append(myLight);
}

function parseLightToObject(json, myObject, lightName) {
    var clight = JSON.parse(json);
    myObject.vuuid = lightName;
    myObject.vname = clight.name;
    myObject.von = clight.state.on;
    myObject.vbri = clight.state.bri;
    myObject.vhue = clight.state.hue;
    myObject.vsat = clight.state.sat;
    myObject.veffect = clight.state.effect;
    myObject.vx = clight.state.xy[0];
    myObject.vy = clight.state.xy[1];
    myObject.vct = clight.state.ct;
    myObject.valert = clight.state.alert;
    myObject.vcolormode = clight.state.colormode;
    myObject.vreachable = clight.state.reachable;
    myObject.vtype = clight.type;
    myObject.vmanufacturername = clight.manufacturername;
    myObject.vmodelid = clight.modelid;
    myObject.vuniqueid = clight.uniqueid;
    myObject.vswversion = clight.swversion;
    myObject.vswconfigid = clight.swconfigid;
    myObject.vproductid = clight.productid;
    myObject.vLastUpdated = getCurrentTime();
}

function getCurrentTime() {
    var date = new Date();
    return date.getMilliseconds(); 
}

function dbgPrint(msg) {
    print('[Hoppla] ' + msg)
}

function Timer() {
    return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root);
}
