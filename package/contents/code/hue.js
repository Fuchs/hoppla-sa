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
var altConnectionEnabled;
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

function getAll(groupModel, lightModel) {
    if(noConnection) {
        return;
    }
    var myUrl = "";
    getJsonFromHue(myUrl, parseAll, baseFail, groupModel, lightModel);
}

/**
 * Get all lights from the hue bridge and
 * fills them into a ListModel
 *
 * @param {ListModel} myModel The model to fill with hue lights.
 */
function getLights(myModel) {
    if(noConnection) {
        return;
    }
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
    if(noConnection) {
        return;
    }
    var myUrl = "lights/" + lightId;
    getJsonFromHue(myUrl, parseLightToModel, baseFail, myModel, lightId);
}

/**
 * Update a specific light with values from hue
 *
 * @param {object} myLight a light entry from the model of a ListView
 */
function updateLight(myLight) {
    if(noConnection) {
        return;
    }
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
    if(noConnection) {
        return;
    }
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
    if(noConnection) {
        return;
    }
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
    if(noConnection) {
        return;
    }
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
    try {
        var myResult = JSON.parse(json);
    }
    catch(e) {
        debugPrint("Failed to parse json: " + json);
        return;
    }
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
    
    if(useAuth) {
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
                    try {
                        var myResult = JSON.parse(json);
                    }
                    catch(e) {
                        debugPrint("Failed to parse json: " + json);
                        return;
                    }
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
        try {
            var myResult = JSON.parse(json);
        }
        catch(e) {
            debugPrint("Failed to parse json: " + json);
            return;
        }
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

function getJsonFromHue(getUrl, successCallback, failureCallback, object, object2) {
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
                    successCallback(json, object, object2);
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
        successCallback(json, object, object2);
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

function parseAll(json, groupModel, lightModel) {
    // Delete current list, even in case of errors 
    // we do not want a cached one
    groupModel.clear();
    lightModel.clear();
    try {
        var myResult = JSON.parse(json);
    }
    catch(e) {
        debugPrint("Failed to parse json: " + json);
        return;
    }
    if(myResult[0]) {
        if(myResult[0].error) {
            if(myResult[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(myResult[0].error.type == 3) {
                //TODO: unavailable
            }
        }
    }
    
    for(var resultName in myResult) {
        if(resultName === "groups") {
            var myGroups = myResult[resultName];
            for(var groupName in myGroups) {
                var cgroup = myGroups[groupName];
                var myGroup = {};
                myGroup.vuuid = groupName;
                myGroup.vname = cgroup.name || i18n("Not available");
                myGroup.vtype = cgroup.type || i18n("Not available");
                myGroup.vlights = cgroup.lights || i18n("Not available");
                myGroup.slights = "" + cgroup.lights || i18n("Not available");
                myGroup.vall_on = cgroup.state.all_on || false;
                myGroup.vany_on = cgroup.state.any_on || false;
                myGroup.vclass = cgroup.class || i18n("Not available");
                myGroup.von = cgroup.action.on || false;
                myGroup.vbri = cgroup.action.bri || 0
                myGroup.vhue = cgroup.action.hue || 0
                myGroup.vsat = cgroup.action.sat || 0
                myGroup.veffect = cgroup.action.effect || i18n("Not available");
                if(cgroup.action.xy && cgroup.action.xy.length > 1) {
                    myGroup.vx = cgroup.action.xy[0] || i18n("Not available");
                    myGroup.vy = cgroup.action.xy[1]  || i18n("Not available");
                }
                else {
                    myGroup.vx = 0;
                    myGroup.xy = 0;
                }
                myGroup.vct = cgroup.action.ct  || 0;
                myGroup.valert = cgroup.action.alert || i18n("Not available");
                myGroup.vcolormode = cgroup.action.colormode  || "ct";
                myGroup.vLastUpdated = getCurrentTime();
                
                groupModel.append(myGroup);
            }
        }
        else if (resultName === "lights") {
            var myLights = myResult[resultName];
            for(var lightName in myLights) {
                var clight = myLights[lightName];
                var myLight = {}
                myLight.vuuid = lightName;
                myLight.vname = clight.name || i18n("Not available");
                myLight.von = clight.state.on || false;
                myLight.vbri = clight.state.bri || 0;
                myLight.vhue = clight.state.hue || 0;
                myLight.vsat = clight.state.sat || 0;
                myLight.veffect = clight.state.effect || i18n("Not available");
                if(clight.state.xy && clight.state.xy.length > 1) {
                    myLight.vx = clight.state.xy[0];
                    myLight.vy = clight.state.xy[1];
                }
                else {
                    myLight.vx = 0;
                    myLight.vy = 0;
                }
                myLight.vct = clight.state.ct || 0;
                myLight.valert = clight.state.alert || i18n("Not available");
                myLight.vcolormode = clight.state.colormode || "ct";
                myLight.vreachable = clight.state.reachable || false;
                myLight.vtype = clight.type || i18n("Not available");
                myLight.vmanufacturername = clight.manufacturername || i18n("Not available");
                myLight.vmodelid = clight.modelid || i18n("Not available");
                myLight.vuniqueid = clight.uniqueid || i18n("Not available");
                myLight.vswversion = clight.swversion || i18n("Not available");
                myLight.vswconfigid = clight.swconfigid || i18n("Not available");
                myLight.vproductid = clight.productid || i18n("Not available");
                myLight.vLastUpdated = getCurrentTime();
                lightModel.append(myLight);
            }
        }
        
        //TODO: config, schedules, scenes, rules, sensors once we support them
    }
}

function parseGroupsToModel(json, listModel, name) {
    // Delete current list, even in case of errors 
    // we do not want a cached one
    listModel.clear();
    try {
        var myGroups = JSON.parse(json);
    }
    catch(e) {
        debugPrint("Failed to parse json: " + json);
        return;
    }
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
        var myGroup = {};
        myGroup.vuuid = groupName;
        myGroup.vname = cgroup.name || i18n("Not available");
        myGroup.vtype = cgroup.type || i18n("Not available");
        myGroup.vlights = cgroup.lights || i18n("Not available");
        myGroup.slights = "" + cgroup.lights || i18n("Not available");
        myGroup.vall_on = cgroup.state.all_on || false;
        myGroup.vany_on = cgroup.state.any_on || false;
        myGroup.vclass = cgroup.class || i18n("Not available");
        myGroup.von = cgroup.action.on || false;
        myGroup.vbri = cgroup.action.bri || 0
        myGroup.vhue = cgroup.action.hue || 0
        myGroup.vsat = cgroup.action.sat || 0
        myGroup.veffect = cgroup.action.effect || i18n("Not available");
        if(cgroup.action.xy && cgroup.action.xy.length > 1) {
            myGroup.vx = cgroup.action.xy[0] || i18n("Not available");
            myGroup.vy = cgroup.action.xy[1]  || i18n("Not available");
        }
        else {
            myGroup.vx = 0;
            myGroup.xy = 0;
        }
        myGroup.vct = cgroup.action.ct  || 0;
        myGroup.valert = cgroup.action.alert || i18n("Not available");
        myGroup.vcolormode = cgroup.action.colormode  || "ct";
        myGroup.vLastUpdated = getCurrentTime();
        
        listModel.append(myGroup);
    }
}

function parseGroupToObject(json, myObject, name) {
    try {
        var cgroup = JSON.parse(json);
    }
    catch(e) {
        debugPrint("Failed to parse json: " + json);
        return;
    }
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
    myObject.vname = cgroup.name || i18n("Not available");
    myObject.vtype = cgroup.type || i18n("Not available");
    myObject.vlights = cgroup.lights || i18n("Not available");
    myObject.slights = "" + cgroup.lights || i18n("Not available");
    myObject.vall_on = cgroup.state.all_on || false;
    myObject.vany_on = cgroup.state.any_on || false;
    myObject.vclass = cgroup.class || i18n("Not available");
    myObject.von = cgroup.action.on || false;
    myObject.vbri = cgroup.action.bri || 0
    myObject.vhue = cgroup.action.hue || 0
    myObject.vsat = cgroup.action.sat || 0
    myObject.veffect = cgroup.action.effect || i18n("Not available");
    if(cgroup.action.xy && cgroup.action.xy.length > 1) {
        myObject.vx = cgroup.action.xy[0] || i18n("Not available");
        myObject.vy = cgroup.action.xy[1]  || i18n("Not available");
    }
    else {
        myObject.vx = 0;
        myObject.xy = 0;
    }
    myObject.vct = cgroup.action.ct  || 0;
    myObject.valert = cgroup.action.alert || i18n("Not available");
    myObject.vcolormode = cgroup.action.colormode  || "ct";
    myObject.vLastUpdated = getCurrentTime();
}

function parseAllLightsToModel(json, listModel, name) {
    listModel.clear();
    try {
        var myLights = JSON.parse(json);
     }
    catch(e) {
        debugPrint("Failed to parse json: " + json);
        return;
    }
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
    for(var lightName in myLights) {
        var clight = myLights[lightName];
        var myLight = {}
        myLight.vuuid = lightName;
        myLight.vname = clight.name || i18n("Not available");
        myLight.von = clight.state.on || false;
        myLight.vbri = clight.state.bri || 0;
        myLight.vhue = clight.state.hue || 0;
        myLight.vsat = clight.state.sat || 0;
        myLight.veffect = clight.state.effect || i18n("Not available");
        if(clight.state.xy && clight.state.xy.length > 1) {
            myLight.vx = clight.state.xy[0];
            myLight.vy = clight.state.xy[1];
        }
        else {
            myLight.vx = 0;
            myLight.vy = 0;
        }
        myLight.vct = clight.state.ct || 0;
        myLight.valert = clight.state.alert || i18n("Not available");
        myLight.vcolormode = clight.state.colormode || "ct";
        myLight.vreachable = clight.state.reachable || false;
        myLight.vtype = clight.type || i18n("Not available");
        myLight.vmanufacturername = clight.manufacturername || i18n("Not available");
        myLight.vmodelid = clight.modelid || i18n("Not available");
        myLight.vuniqueid = clight.uniqueid || i18n("Not available");
        myLight.vswversion = clight.swversion || i18n("Not available");
        myLight.vswconfigid = clight.swconfigid || i18n("Not available");
        myLight.vproductid = clight.productid || i18n("Not available");
        myLight.vLastUpdated = getCurrentTime();
        listModel.append(myLight);
    }
}

function parseLightToModel(json, listModel, lightName) {
    try {
        var clight = JSON.parse(json);
    }
    catch(e) {
        debugPrint("Failed to parse json: " + json);
        return;
    }
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
    var myLight = {};
    myLight.vuuid = lightName;
    myLight.vname = clight.name || i18n("Not available");
    myLight.von = clight.state.on || false;
    myLight.vbri = clight.state.bri || 0;
    myLight.vhue = clight.state.hue || 0;
    myLight.vsat = clight.state.sat || 0;
    myLight.veffect = clight.state.effect || i18n("Not available");
    if(clight.state.xy && clight.state.xy.length > 1) {
        myLight.vx = clight.state.xy[0];
        myLight.vy = clight.state.xy[1];
    }
    else {
        myLight.vx = 0;
        myLight.vy = 0;
    }
    myLight.vct = clight.state.ct || 0;
    myLight.valert = clight.state.alert || i18n("Not available");
    myLight.vcolormode = clight.state.colormode || "ct";
    myLight.vreachable = clight.state.reachable || false;
    myLight.vtype = clight.type || i18n("Not available");
    myLight.vmanufacturername = clight.manufacturername || i18n("Not available");
    myLight.vmodelid = clight.modelid || i18n("Not available");
    myLight.vuniqueid = clight.uniqueid || i18n("Not available");
    myLight.vswversion = clight.swversion || i18n("Not available");
    myLight.vswconfigid = clight.swconfigid || i18n("Not available");
    myLight.vproductid = clight.productid || i18n("Not available");
    myLight.vLastUpdated = getCurrentTime();

    listModel.append(myLight);
}

function parseLightToObject(json, myObject, lightName) {
    try {
        var clight = JSON.parse(json);
    }
    catch(e) {
        debugPrint("Failed to parse json: " + json);
        return;
    }
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
    myObject.vname = clight.name || i18n("Not available");
    myObject.von = clight.state.on || false;
    myObject.vbri = clight.state.bri || 0;
    myObject.vhue = clight.state.hue || 0;
    myObject.vsat = clight.state.sat || 0;
    myObject.veffect = clight.state.effect || i18n("Not available");
    if(clight.state.xy && clight.state.xy.length > 1) {
        myObject.vx = clight.state.xy[0];
        myObject.vy = clight.state.xy[1];
    }
    else {
        myObject.vx = 0;
        myObject.vy = 0;
    }
    myObject.vct = clight.state.ct || 0;
    myObject.valert = clight.state.alert || i18n("Not available");
    myObject.vcolormode = clight.state.colormode || "ct";
    myObject.vreachable = clight.state.reachable || false;
    myObject.vtype = clight.type || i18n("Not available");
    myObject.vmanufacturername = clight.manufacturername || i18n("Not available");
    myObject.vmodelid = clight.modelid || i18n("Not available");
    myObject.vuniqueid = clight.uniqueid || i18n("Not available");
    myObject.vswversion = clight.swversion || i18n("Not available");
    myObject.vswconfigid = clight.swconfigid || i18n("Not available");
    myObject.vproductid = clight.productid || i18n("Not available");
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
