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

var useAltConnection = false;
var altConnectionEnabled = false;
var noConnection = false;

// GETTERS

function initHueConfig() {
    useAltConnection = false;
    altConnectionEnabled = plasmoid.configuration.useAltURL
    noConnection = false;
}

/**
 * Checks whether the hue bridge is configured
 * @return {bool} True if auth and bridge are set, otherwise false
 */
function getHueConfigured() {
    var base = plasmoid.configuration.baseURL 
    var auth = plasmoid.configuration.authToken
    if (!base.trim() || !auth.trim()) {
        // is empty or whitespace
        return false;
    }
    return true;
}

/**
 * Get all lights from the hue bridge and
 * fills them into a ListModel
 *
 * @param {ListModel} myModel The model to fill with hue lights.
 */
function getLights(myModel) {
    var myUrl = "lights";
    getJsonFromHue(myUrl, parseAllLightsToModel, baseFail, myModel, "");
}

/**
 * Get one lights from the hue bridge and fill them into a ListModel
 *
 * @param {ListModel} myList The model to fill with the hue light.
 * @param {string} lightId hue id of the light
 */
function getLight(myModel, lightId) {
    var myUrl = "lights/" + lightId;
    getJsonFromHue(myUrl, parseLightToModel, baseFail, myModel, lightId);
}

/**
 * Update a specific light with values from hue
 *
 * @param {object} myLight a light entry from the model of a ListView
 */
function updateLight(myLight) {
    var myUrl = "lights/" + myLight.vuuid;
    getJsonFromHue(myUrl, parseLightToObject, baseFail, myLight, myLight.vuuid);
}

/**
 * Get all groups from the hue bridge and
 * fills them into a ListModel
 *
 * @param {ListModel} myModel The model to fill with hue groups.
 */
function getGroups(myModel) {
    var myUrl = "groups";
    getJsonFromHue(myUrl, parseGroupsToModel, baseFail, myModel, "");
}


/**
 * Get all lights for a specific group from the hue bridge and
 * fills them into a ListModel
 *
 * @param {ListModel} myList The model to fill with hue groups.
 * @param {string} myLights comma separated string (array syntax) of hue light ids 
 */
function getGroupLights(myList, myLights) {
    if(myLights) {
        myList.clear();
        var array = myLights.split(',');
        for(var index = 0; index < array.length; ++index) {
            getLight(myList, array[index]);
        }
    }
}

/**
 * Update a specific group with values from hue
 *
 * @param {object} myGroup a group entry from the model of a ListView
 */
function updateGroup(myGroup) {
    var myUrl = "groups/" + myGroup.vuuid;
    getJsonFromHue(myUrl, parseGroupToObject, baseFail, myGroup, myGroup.vuuid);
}

// SWITCH

/**
 * Sets a certain hue light on or off
 *
 * @param {string} lightId The philips hue id of the light.
 * @param {bool} on Whether the light should be on (true) or off (false)
 */
function switchLight(lightId, on) {
    var body = on ? '{"on":true}' : '{"on":false}';
    var myUrl = "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

/**
 * Sets a certain hue group on or off
 *
 * @param {string} groupId The philips hue id of the group.
 * @param {bool} on Whether the group should be on (true) or off (false)
 */
function switchGroup(groupId, on) {
    var body = on ? '{"on":true}' : '{"on":false}';
    var myUrl = "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

// GROUP SETTER

/**
 * Sets a certain hue group to a specific brightness
 *
 * @param {string} groupId The philips hue id of the group.
 * @param {int} brightness brightness between 0 and 255, converted to 1-254 by hue
 */
function setGroupBrightness(groupId, brightness) {
    var body = '{"bri":' + brightness + '}';
    var myUrl = "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

/**
 * Sets a certain hue group to a specific white temperature.
 * Will also set the colormode to "ct"
 * See https://developers.meethue.com/documentation/core-concepts
 *
 * @param {string} groupId The philips hue id of the group.
 * @param {int} ct Colour temperature between 153 and 500 mirek
 */
function setGroupColourTemp(groupId, ct) {
    var body = '{"ct":' + ct + ',"colormode": "ct"}';
    var myUrl = "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

/**
 * Sets a certain hue group to a specific colour.
 * Will also set the colormode to "hs"
 * See https://developers.meethue.com/documentation/core-concepts
 *
 * @param {string} groupId The philips hue id of the group.
 * @param {int} hue Hue value between 0 and 65535
 * @param {int} sat Saturation value between 0 and 254
 */
function setGroupColourHS(groupId, hue, sat) {
    var body = '{"hue":' + hue + ',"sat":' + sat + ',"colormode": "hs"}';
    var myUrl = "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

// LIGHT SETTER

/**
 * Sets a certain hue light to a specific brightness
 *
 * @param {string} lightId The philips hue id of the light.
 * @param {int} brightness brightness between 0 and 255, converted to 1-254 by hue
 */
function setLightBrightess(lightId, brightness) {
    var body = '{"bri":' + brightness + '}';
    var myUrl = "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

/**
 * Sets a certain hue light to a specific white temperature.
 * Will also set the colormode to "ct"
 * See https://developers.meethue.com/documentation/core-concepts
 *
 * @param {string} lightId The philips hue id of the light.
 * @param {int} ct Colour temperature between 153 and 500 mirek
 */
function setLightColourTemp(lightId, ct) {
    var body = '{"ct":' + ct + '}';
    var myUrl = "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

/**
 * Sets a certain hue light to a specific colour.
 * Will also set the colormode to "hs"
 * See https://developers.meethue.com/documentation/core-concepts
 *
 * @param {string} lightId The philips hue id of the light.
 * @param {int} hue Hue value between 0 and 65535
 * @param {int} sat Saturation value between 0 and 254
 */
function setLightColourHS(lightId, hue, sat) {
    var body = '{"hue":' + hue + ',"sat":' + sat + '}';
    var myUrl = "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail);
}

// Authenticate

/**
 * Helper function to authenticate with a hue bridge
 * @param {String} bridgeUrl url of the bridge, including protocol (e.g. http://1.2.3.4)
 * @param {String} hostname the Hostname passed to hue, set to "unknowndevice" if empty
 * @param {Function} sCb callback function in case of successful authentication
 * @param {Function} fCb callback function in case of a failure
 * 
 */
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
    var postUrl = bridgeUrl + "/api";;
    postJsonToHue(postUrl, body, attempt, attempts, authSuccess, authFail, sCb, fCb)
}

/**
 * Helper function for authentication, failure case
 */
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

/**
 * Helper function for authentication, success case
 */
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

function getRequest(pUrl, pType, forceBase, forceAlt) {
    var request = new XMLHttpRequest();
    var base = "";
    var useAuth = false;
    var username = "";
    var password = "";
    if((!forceBase && useAltConnection) || forceAlt) {
        base = plasmoid.configuration.altURL
        useAuth = plasmoid.configuration.altUseAuth
        username = plasmoid.configuration.altUsername
        password = plasmoid.configuration.altPassword
        request.timeout = 8000;
    }
    else {
        base = plasmoid.configuration.baseURL
        useAuth = plasmoid.configuration.useAuth
        username = plasmoid.configuration.username
        password = plasmoid.configuration.password
        request.timeout = 2000;
    }
    var auth = plasmoid.configuration.authToken
    var url = base + "/api/" + auth + "/" + pUrl
    
    if(!useAuth) {
        request.open(pType, url, true, username, password);
    }
    else {
        request.open(pType, url);
    }
    return request;
}

function isUsingAltConnection() {
    return useAltConnection;
}

function setUsingAltConnection(useAlt) {
    useAltConnection = useAlt;
}

/**
 * Helper function to check hue connection
 * @param {Function} callback to be called passing a string and boolean
 */
function checkHueConnection (callback, enforce) {
    var getUrl  = "groups" // this is for authed users only
    var request = getRequest(getUrl, 'GET', true, false);
    // should be sufficient for a home connection
    request.timeout = 1000;
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        if (request.status !== 200) {
            if(altConnectionEnabled) {
                var altRequest = getRequest(getUrl, 'GET', false, true);
                altRequest.onreadystatechange = function () {
                    if (altRequest.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }
                    if (altRequest.status !== 200) {
                        callback("none", enforce);
                        return;
                    }
                    
                    var json = altRequest.responseText;
                    var myResult = JSON.parse(json);
                    if(!myResult[0]) {
                        callback("alt", enforce);
                        useAltConnection = true;
                        return;
                    }
                    
                    if(myResult[0].error) {
                        if(myResult[0].error.type == 1) {
                            callback("unauth", enforce);
                            useAltConnection = true;
                            return;
                        }
                    }
                }
                altRequest.send();
            }
            else {
                // No alt configuration configured, main is failing
                callback("none", enforce);
            }
        }
        var json = request.responseText;
        var myResult = JSON.parse(json);
        if(!myResult[0]) {
            callback("main", enforce);
            useAltConnection = false;
            return;
        }
        if(myResult[0].error) {
            if(myResult[0].error.type == 1) {
                callback("unauth", enforce);
                useAltConnection = false;
                return;
            }
        }
    }
    request.send();
}

function getJsonFromHue(getUrl, successCallback, failureCallback, object, name) {
    var request = getRequest(getUrl, 'GET');
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        
        if (request.status !== 200) {
            if(!useAltConnection && altConnectionEnabled) {
                debugPrint("Request to " + getUrl + " failed, trying alt URL")
                useAltConnection = true;
                var altRequest = getRequest(getUrl, 'GET');
                altRequest.onreadystatechange = function () {
                    if (altRequest.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }
                    if (altRequest.status !== 200) {
                        debugPrint("Request to " + getUrl + " failed with alt URL as well")
                        noConnection = true;
                        failureCallback(altRequest);
                    }
                    
                    var json = altRequest.responseText;
                    successCallback(json, object, name);
                    noConnection = false;
                }
                altRequest.send();
            }
            else {
                debugPrint("Request to " + getUrl + " failed, with alt connection or no alt configured")
                failureCallback(request);
                noConnection = true;
            }
        }
        var json = request.responseText;
        successCallback(json, object, name);
        noConnection = false;
    }
    request.send();
}

function putJsonToHue(putUrl, payload, successCallback, failureCallback) {
    var request = getRequest(putUrl, 'PUT');
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        if (request.status !== 200) {
            if(!useAltConnection && altConnectionEnabled) {
                debugPrint("Request to " + putUrl + " failed, trying alt URL")
                useAltConnection = true;
                var altRequest = getRequest(getUrl, 'PUT');
                altRequest.onreadystatechange = function () {
                    if (altRequest.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }
                    
                    if (altRequest.status !== 200) {
                        debugPrint("Request to " + putUrl + " failed with alt URL as well")
                        failureCallback(altRequest);
                        noConnection = true;
                    }
                    
                    var json = altRequest.responseText;
                    successCallback(json, name);
                    noConnection = false;
                }
                altRequest.send();
            }
            else {
                debugPrint("Request to " + putUrl + " failed with alt URL or no alt Url specified")
                failureCallback(request);
                noConnection = true;
            }
        }
        
        var json = request.responseText;
        successCallback(json);
        noConnection = false;
    }
    request.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    request.send(payload);
}

function postJsonToHue(postUrl, body, att, maxAtt, lSuccCb, lFailCb, gSuccCb, gFailCb) {
    if(att > maxAtt) {
        gFailCb("Timeout");
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
    // Delete current list, even in case of errors 
    // we do not want a cached one
    listModel.clear();
    if(myGroups[0]) {
        if(myGroups[0].error) {
            if(myGroups[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(myGroups[0].error.type == 3) {
                //TODO: unavailable
            }
        }
    }
    
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
    if(cgroup[0]) {
        if(cgroup[0].error) {
            if(myGroups[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(myGroups[0].error.type == 3) {
                //TODO: unavailable
            }
        }
    }
    
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

function parseAllLightsToModel(json, listModel, name) {
    var myLights = JSON.parse(json);
    listModel.clear();
    if(myLights[0]) {
        if(myLights[0].error) {
            if(myGroups[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(myGroups[0].error.type == 3) {
                //TODO: unavailable
            }
        }
    }
    
    var total = 0; 
    var on = 0;
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
        total++;
        if(clight.state.on) {
            on++;
        }
    }
    
    plasmoid.toolTipSubText = on + "/" + total + i18n(" lights on");
}

function parseLightToModel(json, listModel, lightName) {
    var clight = JSON.parse(json);
    if(clight[0]) {
        if(clight[0].error) {
            if(myGroups[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(myGroups[0].error.type == 3) {
                //TODO: unavailable
            }
        }
    }
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
    if(clight[0]) {
        if(clight[0].error) {
            if(myGroups[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(myGroups[0].error.type == 3) {
                //TODO: unavailable
            }
        }
    }
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
