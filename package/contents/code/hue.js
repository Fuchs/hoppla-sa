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

var useAltConnection = false;
var initialized = false;
var altConnectionEnabled;
var noConnection = false;
var debug = false;

// INIT

function dbgPrint(msg) {
    if(!debug) {
        return;
    }
    print('[Hoppla-Hue] ' + msg)
}


function initHueConfig() {
    useAltConnection = false;
    altConnectionEnabled = plasmoid.configuration.useAltURL
    noConnection = false;
    initialized = true;
}

// RAW PUT 

/**
 * Function to put raw payload to an url
 * @param {String} url URL after the api/auth/ part
 * @param {String} payload json payload
 */
function putPayloadToUrl(url, payload, succesCallback, failureCallback) {
    putJsonToHue(url, payload, succesCallback, failureCallback, baseDone);
}

/**
 * Returns whether init has been called already
 */
function isInitialized () {
    return initialized;
}

/**
 * Checks whether the hue bridge is configured
 * @return {bool} True if auth and bridge are set, otherwise false
 */
function getHueConfigured() {
    if(!isInitialized()) {
        initHueConfig();
    }
    
    var base = plasmoid.configuration.baseURL 
    var auth = plasmoid.configuration.authToken
    if(!base || !auth) {
        // something went terribly wrong here
        return false;
    }
    if (!base.trim() || !auth.trim()) {
        // is empty or whitespace
        return false;
    }
    return true;
}

function getAll(groupModel, lightModel, doneCallback) {
    if(noConnection) {
        return;
    }
    var myUrl = "";
    getJsonFromHue(myUrl, parseAll, baseFail, doneCallback, groupModel, lightModel);
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
    getJsonFromHue(myUrl, parseAllLightsToModel, baseFail, baseDone, myModel, "");
}

function getNewLights(myModel, doneCallback) {
    if(noConnection) {
        return;
    }
    var myUrl = "lights/new";
    getJsonFromHue(myUrl, parseNewLights, baseFail, doneCallback, myModel, "");
}

function scanNewLights(doneCallback) {
    if(noConnection) {
        return;
    }
    var myUrl = "lights";
    postJsonToHue(myUrl, "", baseSuccess, baseFail, doneCallback);
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
    getJsonFromHue(myUrl, parseLightToModel, baseFail, baseDone, myModel, lightId);
}

/**
 * Helper to fill light names and id 
 * into a model (used by config dialogue) 
 * The model will not be cleared beforehand.
 * @param {ListModel} myModel model to fill with text and value
 */
function getLightsIdName(myModel, doneCb) {
    if(noConnection) {
        dbgPrint("No connection");
        return;
    }
    if(!doneCb) {
        doneCb = baseDone;
    }
    var myUrl = "lights";
    getJsonFromHue(myUrl, parseLightsToSimpleModel, baseFail, doneCb, myModel, "");
}

function getAvailableLightsIdName(myModel) {
    if(noConnection) {
        dbgPrint("No connection");
        return;
    }
    var myUrl = "";
    getJsonFromHue(myUrl, parseAvailableLightsToSimpleModel, baseFail, baseDone, myModel, "");
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
    getJsonFromHue(myUrl, parseLightToObject, baseFail, baseDone, myLight, myLight.vuuid);
}

/**
 * Method to update an existing light
 * @param {string} lightId id of the light to update
 * @param {string} body JSON body
 * @param {function} doneCallback called when done
 */
function modifyLight(lightId, body, doneCallback) {
    var myUrl = "lights/" + lightId;
    putJsonToHue(myUrl, body, baseSuccess, baseFail, doneCallback);
}

/**
 * Method to delete an existing light
 * @param {string} lightId id of the light to update
 * @param {function} doneCallback called when done
 */
function deleteLight(lightId, doneCallback) {
    var myUrl = "lights/" + lightId;
    deleteRequestToHue(myUrl, baseSuccess, baseFail, doneCallback);
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
    getJsonFromHue(myUrl, parseGroupsToModel, baseFail, baseDone, myModel, "");
}

/**
 * Helper to fill group names and id, 
 * into a model (used by config dialogue). 
 * The model will not be cleared beforehand.
 * @param {ListModel} myModel model to fill with text and value
 */
function getGroupsIdName(myModel, doneCb) {
    if(noConnection) {
        return;
    }
    if(!doneCb) {
        doneCb = baseDone;
    }
    var myUrl = "groups";
    getJsonFromHue(myUrl, parseGroupsToSimpleModel, baseFail, doneCb, myModel, "");
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
    getJsonFromHue(myUrl, parseGroupToObject, baseFail, baseDone, myGroup, myGroup.vuuid);
}

/**
 * Method to create a new group
 * @param {string} body JSON body
 * @param {function} doneCallback called when done
 */
function createGroup(body, doneCallback) {
    var myUrl = "groups";
    postJsonToHue(myUrl, body, baseSuccess, baseFail, doneCallback);
}

/**
 * Method to update an existing group
 * @param {string} groupId id of the group to update
 * @param {string} body JSON body
 * @param {function} doneCallback called when done
 */
function modifyGroup(groupId, body, doneCallback) {
    var myUrl = "groups/" + groupId;
    putJsonToHue(myUrl, body, baseSuccess, baseFail, doneCallback);
}

/**
 * Method to delete an existing group
 * @param {string} groupId id of the group to update
 * @param {function} doneCallback called when done
 */
function deleteGroup(groupId, doneCallback) {
    var myUrl = "groups/" + groupId;
    deleteRequestToHue(myUrl, baseSuccess, baseFail, doneCallback);
}

/**
 * method to fill schedules into a model
 * @param {ListModel} myModel model to fill
 */
function getSchedulesIdName(myModel) {
    if(noConnection) {
        dbgPrint("No connection");
        return;
    }
    var myUrl = "schedules";
    getJsonFromHue(myUrl, parseSchedulesToSimpleModel, baseFail, baseDone, myModel, "");
}

/**
 * Method to create a new schedule
 * @param {string} body JSON body
 * @param {function} doneCallback called when done
 */
function createSchedule(body, doneCallback) {
    var myUrl = "schedules";
    postJsonToHue(myUrl, body, baseSuccess, baseFail, doneCallback);
}

/**
 * Method to update an existing schedule
 * @param {string} scheduleId id of the schedule to update
 * @param {string} body JSON body
 * @param {function} doneCallback called when done
 */
function modifySchedule(scheduleId, body, doneCallback) {
    var myUrl = "schedules/" + scheduleId;
    putJsonToHue(myUrl, body, baseSuccess, baseFail, doneCallback);
}

/**
 * Method to delete an existing schedule
 * @param {string} scheduleId id of the schedule to update
 * @param {function} doneCallback called when done
 */
function deleteSchedule(scheduleId, doneCallback) {
    var myUrl = "schedules/" + scheduleId;
    deleteRequestToHue(myUrl, baseSuccess, baseFail, doneCallback);
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
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
}

/**
 * Sets a certain hue to blink
 * @param {string} lightId The philips hue id of the light.
 * @param {string} type Hue supported types, "none", "select" (once), "lselect" (15 sec)
 */
function blinkLight(lightId, type) {
    var body = '{"alert": "' + type + '"}';
    var myUrl = "lights/" + lightId + "/state";
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
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
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
}

/**
 * Sets a certain hue group to blink
 *
 * @param {string} groupId The philips hue id of the group.
 * @param {string} type Hue supported types, "none", "select" (once), "lselect" (15 sec)
 */
function blinkGroup(groupId, type) {
    var body = '{"alert": "' + type + '"}';
    var myUrl = "groups/" + groupId + "/action";
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
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
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
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
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
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
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
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
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
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
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
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
    putJsonToHue(myUrl, body, baseSuccess, baseFail, baseDone);
}

// Schedules



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
    var postUrl = bridgeUrl + "/api";
    postAuthToHue(postUrl, body, attempt, attempts, authSuccess, authFail, sCb, fCb)
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
        postAuthToHue(postUrl, body, attempt, maxAtt, authSuccess, authFail, gSuccCb, gFailCb)
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
        dbgPrint("Failed to parse json: " + json);
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
                postAuthToHue(postUrl, body, attempt, maxAtt, authSuccess, authFail, gSuccCb, gFailCb)
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
        postAuthToHue(postUrl, body, attempt, maxAtt, authSuccess, authFail, gSuccCb, gFailCb)
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
                        dbgPrint("Failed to parse json: " + json);
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
            dbgPrint("Failed to parse json: " + json);
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

/**
 * Function to get JSON from the Hue bridge
 * @param {String} getUrl the URL to send the GET request to
 * @param {function} successCallback call on success, json, object, object2 and a done callback as params
 * @param {function} failureCallback call on failure, request and done callback as params
 * @param {function} doneCallback called when all is handled
 * @param {Object} object object to pass to the success function, e.g. a model 
 * @param {Object} object2 object to pass to the success function, e.g. a model 
 */
function getJsonFromHue(getUrl, successCallback, failureCallback, doneCallback, object, object2) {
    var request = getRequest(getUrl, 'GET');
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        
        if (request.status !== 200) {
            if(!useAltConnection && altConnectionEnabled) {
                dbgPrint("Request to " + getUrl + " failed, trying alt URL")
                useAltConnection = true;
                var altRequest = getRequest(getUrl, 'GET');
                altRequest.onreadystatechange = function () {
                    if (altRequest.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }
                    if (altRequest.status !== 200) {
                        dbgPrint("Request to " + getUrl + " failed with alt URL as well")
                        noConnection = true;
                        failureCallback(altRequest, doneCallback);
                    }
                    
                    var json = altRequest.responseText;
                    successCallback(json, object, object2, doneCallback);
                    noConnection = false;
                }
                altRequest.send();
            }
            else {
                dbgPrint("Request to " + getUrl + " failed, with alt connection or no alt configured")
                dbgPrint("Use alt: " + useAltConnection + " Enabled alt: " + altConnectionEnabled);
                failureCallback(request, doneCallback);
                noConnection = true;
            }
        }
        var json = request.responseText;
        successCallback(json, object, object2, doneCallback);
        noConnection = false;
    }
    request.send();
}

/**
 * Function to put JSON to the Hue bridge
 * @param {String} putUrl the URL to send the PUT request to
 * @param {String} payload the content of the PUT request
 * @param {function} successCallback call on success, json, object, object2 and a done callback as params
 * @param {function} failureCallback call on failure, request and done callback as params
 * @param {function} doneCallback called when all is handled
 */
function putJsonToHue(putUrl, payload, successCallback, failureCallback, doneCallback) {
    var request = getRequest(putUrl, 'PUT');
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        if (request.status !== 200) {
            if(!useAltConnection && altConnectionEnabled) {
                dbgPrint("Request to " + putUrl + " failed, trying alt URL")
                useAltConnection = true;
                var altRequest = getRequest(getUrl, 'PUT');
                altRequest.onreadystatechange = function () {
                    if (altRequest.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }
                    
                    if (altRequest.status !== 200) {
                        dbgPrint("Request to " + putUrl + " failed with alt URL as well")
                        failureCallback(altRequest, doneCallback);
                        noConnection = true;
                    }
                    
                    var json = altRequest.responseText;
                    successCallback(json, doneCallback);
                    noConnection = false;
                }
                altRequest.send();
            }
            else {
                dbgPrint("Request to " + putUrl + " failed with alt URL or no alt Url specified")
                failureCallback(request, doneCallback);
                noConnection = true;
            }
        }
        
        var json = request.responseText;
        successCallback(json, doneCallback);
        noConnection = false;
    }
    request.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    request.send(payload);
}

/**
 * Function to post JSON to the Hue bridge
 * @param {String} putUrl the URL to send the POST request to
 * @param {String} payload the content of the POST request
 * @param {function} successCallback call on success, json, object, object2 and a done callback as params
 * @param {function} failureCallback call on failure, request and done callback as params
 * @param {function} doneCallback called when all is handled
 */
function postJsonToHue(postUrl, payload, successCallback, failureCallback, doneCallback) {
    var request = getRequest(postUrl, 'POST');
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        if (request.status !== 200) {
            if(!useAltConnection && altConnectionEnabled) {
                dbgPrint("Request to " + postUrl + " failed, trying alt URL")
                useAltConnection = true;
                var altRequest = getRequest(getUrl, 'POST');
                altRequest.onreadystatechange = function () {
                    if (altRequest.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }
                    
                    if (altRequest.status !== 200) {
                        dbgPrint("Request to " + postUrl + " failed with alt URL as well")
                        failureCallback(altRequest, doneCallback);
                        noConnection = true;
                    }
                    
                    var json = altRequest.responseText;
                    successCallback(json, doneCallback);
                    noConnection = false;
                }
                altRequest.send();
            }
            else {
                dbgPrint("Request to " + postUrl + " failed with alt URL or no alt Url specified")
                failureCallback(request, doneCallback);
                noConnection = true;
            }
        }
        
        var json = request.responseText;
        successCallback(json, doneCallback);
        noConnection = false;
    }
    request.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    request.send(payload);
}

/**
 * Function to post JSON to the Hue bridge for authentication
 * @param {String} putUrl the URL to send the POST request to
 * @param {String} body the content of the POST request
 * @param {int} att current attempt
 * @param {int} maxAtt maximal amount of attempts
 * @param {function} lSuccCb call on success
 * @param {function} lFailCb call on failure
 *
 */
function postAuthToHue(postUrl, body, att, maxAtt, lSuccCb, lFailCb, gSuccCb, gFailCb) {
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

/**
 * Function to post JSON to the Hue bridge
 * @param {String} putUrl the URL to send the DELETE request to
 * @param {function} successCallback call on success, json, object, object2 and a done callback as params
 * @param {function} failureCallback call on failure, request and done callback as params
 * @param {function} doneCallback called when all is handled
 */
function deleteRequestToHue(deleteUrl, successCallback, failureCallback, doneCallback) {
    var request = getRequest(deleteUrl, 'DELETE');
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        if (request.status !== 200) {
            if(!useAltConnection && altConnectionEnabled) {
                dbgPrint("Request to " + deleteUrl + " failed, trying alt URL")
                useAltConnection = true;
                var altRequest = getRequest(getUrl, 'DELETE');
                altRequest.onreadystatechange = function () {
                    if (altRequest.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }
                    
                    if (altRequest.status !== 200) {
                        dbgPrint("Request to " + deleteUrl + " failed with alt URL as well")
                        failureCallback(altRequest, doneCallback);
                        noConnection = true;
                    }
                    
                    var json = altRequest.responseText;
                    successCallback(json, doneCallback);
                    noConnection = false;
                }
                altRequest.send();
            }
            else {
                dbgPrint("Request to " + deleteUrl + " failed with alt URL or no alt Url specified")
                failureCallback(request, doneCallback);
                noConnection = true;
            }
        }
        
        var json = request.responseText;
        successCallback(json, doneCallback);
        noConnection = false;
    }
    request.send();
}

/**
 * Skeleton function to call on success, will just call doneCallback
 */
function baseSuccess(json, doneCallback) {
    doneCallback(true, json);
}

/**
 * Skeleton function to call on all done, will do nothing
 */
function baseDone(success, json) {
}


/**
 * Skeleton function to call on failure, will print debug output and call doneCallback
 * @param {XHTTPRequest} request 
 * @param {function} doneCallback will be called at the end
 */
function baseFail(request, doneCallback) {
    dbgPrint("Communicating with hue failed");
    if(request.status) {
        dbgPrint("Status: " + request.status);
    }
    if(request.responseText) {
        dbgPrint("Response: " + request.responseText);
    }
    
    doneCallback(false, request);
}

function parseAll(json, groupModel, lightModel, doneCallback) {
    // Delete current list, even in case of errors 
    // we do not want a cached one
    groupModel.clear();
    lightModel.clear();
    try {
        var myResult = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
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
                myGroup.ttype = i18n(cgroup.type) || i18n("Not available");
                myGroup.vlights = cgroup.lights || i18n("Not available");
                myGroup.slights = "" + cgroup.lights || i18n("Not available");
                myGroup.vall_on = cgroup.state.all_on || false;
                myGroup.vany_on = cgroup.state.any_on || false;
                myGroup.vclass = cgroup.class || i18n("Not available");
                myGroup.tclass = i18n(cgroup.class) || i18n("Not available");
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
                
                if(cgroup.action.hue || cgroup.action.sat || cgroup.action.xy) {
                    myGroup.vHasColour = true;
                }
                else {
                    myGroup.vHasColour = false;
                }
                
                if(cgroup.action.ct) {
                    myGroup.vHasTemperature = true;
                }
                else {
                    myGroup.vHasTemperature = false;
                }
                
                myGroup.vct = cgroup.action.ct  || 0;
                myGroup.valert = cgroup.action.alert || i18n("Not available");
                myGroup.vcolormode = cgroup.action.colormode  || "none";
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
                
                if(clight.state.hue || clight.state.sat || clight.state.xy) {
                    myLight.vHasColour = true;
                }
                else {
                    myLight.vHasColour = false;
                }
                
                if(clight.state.ct){
                    myLight.vHasTemperature = true;
                }
                else {
                    myLight.vHasTemperature = false;
                }
                
                myLight.vct = clight.state.ct || 0;
                myLight.valert = clight.state.alert || i18n("Not available");
                myLight.vcolormode = clight.state.colormode || "none";
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
    
    doneCallback(true, json);
}

function parseGroupsToSimpleModel(json, listModel, name, doneCallback) {
    try {
        var myGroups = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
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
        myGroup.name = cgroup.name;
        myGroup.type = cgroup.type || i18n("Not available");
        myGroup.class = cgroup.class || i18n("Not available");
        if(myGroup.type == "LightGroup" || myGroup.type == "Room") {
            myGroup.uuid = groupName;
            myGroup.text = groupName + ": " + cgroup.name;
            myGroup.value = "" + groupName;
            myGroup.tclass = i18n(cgroup.class);
            myGroup.vlights = cgroup.lights || i18n("Not available");
            myGroup.slights = "" + cgroup.lights || i18n("Not available");
            listModel.append(myGroup);
        }
        else {
            dbgPrint("Got a group we can't handle: " + groupName + " with type: " + cgroup.type);
            continue;
        }
    }
    doneCallback(true, json);
}

function parseGroupsToModel(json, listModel, name, doneCallback) {
    // Delete current list, even in case of errors 
    // we do not want a cached one
    listModel.clear();
    try {
        var myGroups = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
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
        myGroup.ttype = i18n(cgroup.type) || i18n("Not available");
        myGroup.vlights = cgroup.lights || i18n("Not available");
        myGroup.slights = "" + cgroup.lights || i18n("Not available");
        myGroup.vall_on = cgroup.state.all_on || false;
        myGroup.vany_on = cgroup.state.any_on || false;
        myGroup.vclass = cgroup.class || i18n("Not available");
        myGroup.tclass = i18n(cgroup.class) || i18n("Not available");
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
        myGroup.vcolormode = cgroup.action.colormode  || "none";
        myGroup.vLastUpdated = getCurrentTime();
        
        if(cgroup.action.hue || cgroup.action.sat || cgroup.action.xy) {
            myGroup.vHasColour = true;
        }
        else {
            myGroup.vHasColour = false;
        }
        
        if(cgroup.action.ct) {
            myGroup.vHasTemperature = true;
        }
        else {
            myGroup.vHasTemperature = false;
        }
        
        listModel.append(myGroup);
    }
    doneCallback(true, json);
}

function parseGroupToObject(json, myObject, name, doneCallback) {
    try {
        var cgroup = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
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
    myObject.ttype = i18n(cgroup.type) || i18n("Not available");
    myObject.vlights = cgroup.lights || i18n("Not available");
    myObject.slights = "" + cgroup.lights || i18n("Not available");
    myObject.vall_on = cgroup.state.all_on || false;
    myObject.vany_on = cgroup.state.any_on || false;
    myObject.vclass = cgroup.class || i18n("Not available");
    myObject.tclass = i18n(cgroup.class) || i18n("Not available");
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
    myObject.vcolormode = cgroup.action.colormode  || "none";
    myObject.vLastUpdated = getCurrentTime();
    
    if(cgroup.action.hue || cgroup.action.sat || cgroup.action.xy) {
        myObject.vHasColour = true;
    }
    else {
        myObject.vHasColour = false;
    }
    
    if(cgroup.action.ct) {
        myObject.vHasTemperature = true;
    }
    else {
        myObject.vHasTemperature = false;
    }
    
    doneCallback(true, json);
    
}

function parseLightsToSimpleModel(json, listModel, name, doneCallback) {
    try {
        var myLights = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
        return;
    }
    if(myLights[0]) {
        if(myLights[0].error) {
            if(myLights[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(myLights[0].error.type == 3) {
                //TODO: unavailable
            }
        }
    }
    
    for(var lightName in myLights) {
        var cLight = myLights[lightName];
        var myLight = {};
        myLight.uuid = lightName;
        myLight.name = cLight.name || i18n("Not available");
        myLight.text = lightName + ": " + cLight.name;
        myLight.value = "" + lightName;
        listModel.append(myLight);
    }
    doneCallback(true, json);
}

function parseNewLights(json, listModel, name, doneCallback) {
    try {
        var myLights = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
        return;
    }
    if(myLights[0]) {
        if(myLights[0].error) {
            if(myLights[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(myLights[0].error.type == 3) {
                //TODO: unavailable
            }
        }
    }
    
    listModel.clear();
    
    for(var lightName in myLights) {
        if(lightName != "lastscan") {
            var cLight = myLights[lightName];
            var myLight = {};
            myLight.uuid = lightName;
            myLight.name = cLight.name || i18n("Not available");
            myLight.text = lightName + ": " + cLight.name;
            myLight.value = "" + lightName;
            listModel.append(myLight);
        }
    }
    doneCallback(true, json);
}

function parseAvailableLightsToSimpleModel(json, listModel, name, doneCallback) {
    try {
        var myResult = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
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
    
    var usedLight = []
    
    var myGroups = myResult["groups"];
    for(var groupName in myGroups) {
        var cgroup = myGroups[groupName];
        if(cgroup.lights) {
            for(var light in  cgroup.lights) {
                usedLight.push(cgroup.lights[light]);
            }
        }
    }
    
    var foundLights = false;
    
    var myLights = myResult["lights"];
    for(var lightName in myLights) {
        foundLights = true;
        if(usedLight.indexOf(lightName) >= 0) {
        }
        else {
            var cLight = myLights[lightName];
            var myLight = {};
            myLight.uuid = lightName;
            myLight.name = cLight.name || i18n("Not available");
            myLight.text = lightName + ": " + cLight.name;
            myLight.value = "" + lightName
            listModel.append(myLight);
        }
    }
    if(foundLights && listModel.count == 0) {
        var txtNone = i18n("No lights without a room available");
        listModel.append({ uuid: "-1", name: txtNone, text: txtNone, value: txtNone})
    }
    
    doneCallback(true, json);
}

function parseAllLightsToModel(json, listModel, name, doneCallback) {
    listModel.clear();
    try {
        var myLights = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
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
        
        if(clight.state.hue || clight.state.sat || clight.state.xy) {
            myLight.vHasColour = true;
        }
        else {
            myLight.vHasColour = false;
        }
        
        myLight.vct = clight.state.ct || 0;
        myLight.valert = clight.state.alert || i18n("Not available");
        myLight.vcolormode = clight.state.colormode || "none";
        myLight.vreachable = clight.state.reachable || false;
        myLight.vtype = clight.type || i18n("Not available");
        myLight.vmanufacturername = clight.manufacturername || i18n("Not available");
        myLight.vmodelid = clight.modelid || i18n("Not available");
        myLight.vuniqueid = clight.uniqueid || i18n("Not available");
        myLight.vswversion = clight.swversion || i18n("Not available");
        myLight.vswconfigid = clight.swconfigid || i18n("Not available");
        myLight.vproductid = clight.productid || i18n("Not available");
        myLight.vLastUpdated = getCurrentTime();
        
        if(clight.state.ct){
            myLight.vHasTemperature = true;
        }
        else {
            myLight.vHasTemperature = false;
        }
        
        listModel.append(myLight);
    }
    
    doneCallback(true, json);
}

function parseLightToModel(json, listModel, lightName, doneCallback) {
    try {
        var clight = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
        return;
    }
    if(clight[0]) {
        if(clight[0].error) {
            if(clight[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(clight[0].error.type == 3) {
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
    myLight.vcolormode = clight.state.colormode || "none";
    myLight.vreachable = clight.state.reachable || false;
    myLight.vtype = clight.type || i18n("Not available");
    myLight.vmanufacturername = clight.manufacturername || i18n("Not available");
    myLight.vmodelid = clight.modelid || i18n("Not available");
    myLight.vuniqueid = clight.uniqueid || i18n("Not available");
    myLight.vswversion = clight.swversion || i18n("Not available");
    myLight.vswconfigid = clight.swconfigid || i18n("Not available");
    myLight.vproductid = clight.productid || i18n("Not available");
    myLight.vLastUpdated = getCurrentTime();
    
    if(clight.state.hue || clight.state.sat || clight.state.xy) {
        myLight.vHasColour = true;
    }
    else {
        myLight.vHasColour = false;
    }
    
    if(clight.state.ct){
        myLight.vHasTemperature = true;
    }
    else {
        myLight.vHasTemperature = false;
    }
    
    listModel.append(myLight);
    
    doneCallback(true, json);
}

function parseLightToObject(json, myObject, lightName, doneCallback) {
    try {
        var clight = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
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
    myObject.vcolormode = clight.state.colormode || "none";
    myObject.vreachable = clight.state.reachable || false;
    myObject.vtype = clight.type || i18n("Not available");
    myObject.vmanufacturername = clight.manufacturername || i18n("Not available");
    myObject.vmodelid = clight.modelid || i18n("Not available");
    myObject.vuniqueid = clight.uniqueid || i18n("Not available");
    myObject.vswversion = clight.swversion || i18n("Not available");
    myObject.vswconfigid = clight.swconfigid || i18n("Not available");
    myObject.vproductid = clight.productid || i18n("Not available");
    myObject.vLastUpdated = getCurrentTime();
    
    if(clight.state.hue || clight.state.sat || clight.state.xy) {
        myObject.vHasColour = true;
    }
    else {
        myObject.vHasColour = false;
    }
    
    if(clight.state.ct){
        myObject.vHasTemperature = true;
    }
    else {
        myObject.vHasTemperature = false;
    }
    
    doneCallback(true, json);
}

function parseSchedulesToSimpleModel(json, listModel, name, doneCallback) {
    try {
        var mySchedules = JSON.parse(json);
    }
    catch(e) {
        dbgPrint("Failed to parse json: " + json);
        doneCallback(false, json);
        return;
    }
    if(mySchedules[0]) {
        if(mySchedules[0].error) {
            if(mySchedules[0].error.type == 1) {
                //TODO: Unauthorized
            }
            if(mySchedules[0].error.type == 3) {
                //TODO: unavailable
            }
        }
    }
    
    for(var scheduleName in mySchedules) {
        var cSchedule = mySchedules[scheduleName];
        var mySchedule = {};
        mySchedule.uuid = scheduleName;
        mySchedule.name = cSchedule.name;
        mySchedule.text = scheduleName + ": " + cSchedule.name;
        mySchedule.value = "" + scheduleName
        mySchedule.description = cSchedule.description || i18n("Not available");
        if(cSchedule.command) {
            mySchedule.address = cSchedule.command.address;
            mySchedule.body = JSON.stringify(cSchedule.command.body);
            mySchedule.method = cSchedule.command.method;
            mySchedule.command = cSchedule.command;
        }
        mySchedule.localtime =  cSchedule.localtime || i18n("Not available");
        mySchedule.time = cSchedule.time || i18n("Not available");
        mySchedule.created = cSchedule.created || i18n("Not available");
        mySchedule.status = cSchedule.status || i18n("disabled");
        if(mySchedule.status == "enabled") {
            mySchedule.pstatus = i18n("on");
        }
        else {
            mySchedule.pstatus = i18n("off");
        }
        mySchedule.recycle = cSchedule.recycle || i18n("Not available");
        mySchedule.autodelete = cSchedule.autodelete || false
        
        // Prefer localtime over time, as per Hue API
        if(cSchedule.localtime) {
            mySchedule.ptime = fmtTimeHumReadable(cSchedule.localtime, true)
        }
        else if(cSchedule.time) {
            mySchedule.ptime = fmtTimeHumReadable(cSchedule.time, false)
        }
        else {
            mySchedule.ptime = i18n("Not available");
        }
        
        listModel.append(mySchedule);
    }
    doneCallback(true, json);
}

/**
 * Helper to clear a model and fill it with all supported room classes 
 * @param {ListModel} myModel model to fill
 * Adds: name (Hue), translatedName (i18n), iconName (lowercase, stripped whitespace)
 */
function fillWithClasses(myModel) {
    // We do these one by one so we can translate them
    myModel.clear();
    myModel.append({name: "Living room", translatedName: i18n("Living room"), iconName: "livingroom"});
    myModel.append({name: "Kitchen", translatedName: i18n("Kitchen"), iconName: "kitchen"});
    myModel.append({name: "Dining", translatedName: i18n("Dining"), iconName: "dining"});
    myModel.append({name: "Bedroom", translatedName: i18n("Bedroom"), iconName: "bedroom"});
    myModel.append({name: "Kids bedroom", translatedName: i18n("Kids bedroom"), iconName: "kidsbedroom"});
    myModel.append({name: "Bathroom", translatedName: i18n("Bathroom"), iconName: "bathroom"});
    myModel.append({name: "Nursery", translatedName: i18n("Nursery"), iconName: "nursery"});
    myModel.append({name: "Recreation", translatedName: i18n("Recreation"), iconName: "recreation"});
    myModel.append({name: "Office", translatedName: i18n("Office"), iconName: "office"});
    myModel.append({name: "Gym", translatedName: i18n("Gym"), iconName: "gym"});
    myModel.append({name: "Hallway", translatedName: i18n("Hallway"), iconName: "hallway"});
    myModel.append({name: "Toilet", translatedName: i18n("Toilet"), iconName: "toilet"});
    myModel.append({name: "Front door", translatedName: i18n("Front door"), iconName: "frontdoor"});
    myModel.append({name: "Garage", translatedName: i18n("Garage"), iconName: "garage"});
    myModel.append({name: "Terrace", translatedName: i18n("Terrace"), iconName: "terrace"});
    myModel.append({name: "Garden", translatedName: i18n("Garden"), iconName: "garden"});
    myModel.append({name: "Driveway", translatedName: i18n("Driveway"), iconName: "driveway"});
    myModel.append({name: "Carport", translatedName: i18n("Carport"), iconName: "carport"});
    myModel.append({name: "Other", translatedName: i18n("Other"), iconName: "other"});
}

/**
 * Helper function to get the current time in milliseconds
 */
function getCurrentTime() {
    var date = new Date();
    return date.getMilliseconds(); 
}

/**
 * Helper to format time human readable
 * See https://developers.meethue.com/documentation/datatypes-and-time-patterns#16_time_patterns
 * @param {String} strHueTime string formatted as per above
 * @param {bool} isLocalTime whether the time is local
 */
function fmtTimeHumReadable(strHueTime, isLocalTime) {
    var isWeekly = false;
    var isTime = false;
    var isRec = false;
    var isRandom = false;
    var isAbsolute = false;
    var bitMask = "";
    var strTime = "";
    var strRandom = "";
    var strRec = "";
    var strAbsolute = "";
    
    var strReadable = "";
    
    for (var i = 0, len = strHueTime.length; i < len; i++) {
        if(strHueTime[i] == "P" || strHueTime[i] == "/") {
            // we simply ignore these, as they are not needed
            continue;
        }
        if(strHueTime[i] == "R") {
            isRec = true;
            continue;
        }
        if(strHueTime[i] == "W") {
            isWeekly = true; 
            continue; 
        }
        if(strHueTime[i] == "T") {
            isTime = true;
            continue;
        }
        if(strHueTime[i] == "A") {
            isRandom = true;
            continue;
        }
        if(isWeekly && !isTime && !isRandom) {
            bitMask += strHueTime[i]
            continue;
        }
        if(isRec && !isTime && !isRandom) {
            strRec += strHueTime[i];
            continue;
        }
        if(isTime && !isRandom) {
            strTime += strHueTime[i];
            continue;
        }
        if(isRandom) {
            strRandom += strHueTime[i];
            continue;
        }
        if(!isTime && !isRandom) {
            isAbsolute = true;
            strAbsolute += strHueTime[i];
        }
    }
    
    if(bitMask != "") {
        var numMask = parseInt(bitMask);
        var bits = arrayFromMask(numMask);
        
        var F_MON = false;
        var F_TUE = false;
        var F_WED = false;
        var F_THU = false;
        var F_FRI = false;
        var F_SAT = false;
        var F_SUN = false;
        
        if(bits.length = 7) {
            F_MON = bits[6]; // 0000001
            F_TUE = bits[5]; // 0000010
            F_WED = bits[4]; // 0000100
            F_THU = bits[3]; // 0001000
            F_FRI = bits[2]; // 0010000
            F_SAT = bits[1]; // 0100000
            F_SUN = bits[0]; // 1000000
        }
        
        strReadable += i18n("Every") + " ";
        
        if(F_MON && F_TUE && F_WED && F_THU && F_FRI && F_SAT && F_SUN) {
            strReadable += i18n("day");
        }
        else if(F_MON && F_TUE && F_WED && F_THU && F_FRI) {
            strReadable += i18n("weekday");
        }
        else if(F_SAT && F_SUN) {
            strReadable += i18n("weekend");
        }
        else {
            if(F_MON) {
                strReadable += i18n("Mon, ");
            }
            if(F_TUE) {
                strReadable += i18n("Tue, ");
            }
            if(F_WED) {
                strReadable += i18n("Wed, ");
            }
            if(F_THU) {
                strReadable += i18n("Thu, ");
            }
            if(F_FRI) {
                strReadable += i18n("Fri, ");
            }
            if(F_SAT) {
                strReadable += i18n("Sat, ");
            }
            if(F_SUN) {
                strReadable += i18n("Sun, ");
            }
        }
    }
    else {
        if(!isAbsolute) {
            if(!isRec) {
                strReadable += i18n("Once") 
            }
            else if (strRec) {
                strReadable += strRec + " " + i18n("times");
            }
            else {
                strReadable += i18n("Forever");
            }
        }
        else {
            strReadable += i18n("At") + " " + strAbsolute + " ";
        }
    }
    
    
    if(strTime) {
        strReadable += " " + i18n("at") + " " + strTime;
        if(!isLocalTime) {
            strReadable += i18n("UTC");
        }
    }
    
    if(strRandom) {
        strReadable += " " + i18n("+ random:") + " " + strRandom; 
        if(!isLocalTime) {
            strReadable += i18n("UTC");
        }
    }
    
    return strReadable;
}

/**
 * Helper method to parse a hue time string
 * @param {string} strTime the time to parse
 * @return {object} timeObject with values
 */
function parseHueTimeString(strTime) {
    var timeObj = {};
    timeObj.valid = true;
    timeObj.isRecurring = false;
    timeObj.isWeekly = false;
    timeObj.isOneTimer = false;
    timeObj.isAbsolute = false;
    
    if(!strTime) {
        dbgPrint("Empty string, invalid");
        timeObj.valid = false;
        return timeObj;
    }
    try {
        if(strTime.charAt(0) == "P") {
            timeObj.isOneTimer = true;
            
        }
        else if(strTime.charAt(0) == "R") {
            timeObj.isReccuring = true;
            var rec = "";
            for(var i = 0; i < 3; ++i) {
                var cha = strTime.charAt(1 + i);
                if(cha == "/") {
                    break
                }
                else {
                    rec += cha;
                }
            }
            
            if(rec && rec != "0") {
                timeObj.rec = parseInt(rec);
                timeObj.forever = false;
            }
            else {
                timeObj.rec = 0;
                timeObj.forever = true;
            }
        }
        else if(strTime.charAt(0) == "W") {
            timeObj.isWeekly = true;
            var bitMask = "";
            for(var i = 0; i < 3; ++i) {
                var cha = strTime.charAt(1 + i);
                if(cha == "/") {
                    break
                }
                else {
                    bitMask += cha;
                }
            }
            
            if(bitMask) {
                var bits = arrayFromMask(bitMask);
                
                if(bits.length = 7) {
                    timeObj.onMon = bits[6]; // 0000001
                    timeObj.onTue = bits[5]; // 0000010
                    timeObj.onWed = bits[4]; // 0000100
                    timeObj.onThu = bits[3]; // 0001000
                    timeObj.onFri = bits[2]; // 0010000
                    timeObj.onSat = bits[1]; // 0100000
                    timeObj.onSun = bits[0]; // 1000000
                }
                else {
                    timeObj.valid = false;
                    return timeObj;
                }
            }
            else {
                timeObj.valid = false;
                return timeObj;
            }
        }
        else {
            timeObj.isAbsolute = true;
            timeObj.date = strTime.substring(0, 10);
            timeObj.year = strTime.substring(0,4);
            timeObj.month = strTime.substring(5,7);
            timeObj.day = strTime.substring(8,10)
        }
        
        var time = strTime.indexOf("T");
        if(time < 0) {
            timeObj.valid = false;
            return timeObj;
        }
        var timeString = strTime.substring(time + 1, time + 8)
        timeObj.hours = parseInt(timeString.substring(0,2));
        timeObj.minutes = parseInt(timeString.substring(3,5));
        timeObj.seconds = parseInt(timeString.substring(6,8));
        
        var rand = strTime.indexOf("A");
        if(rand < 0) {
            timeObj.hasRandom = false;
        }
        else {
            timeObj.hasRandom = true;
            timeString = strTime.substring(rand + 1, rand + 8)
            timeObj.randHours = parseInt(timeString.substring(0,2));
            timeObj.randMinutes = parseInt(timeString.substring(3,5));
            timeObj.randSeconds = parseInt(timeString.substring(6,8));
        }
        
        return timeObj;
        
    }
    catch (e) {
        dbgPrint("Error in parseHueTimeString: " + e);
        timeObj.valid = false;
        return timeObj;
    }
}


/**
 * Helper method to parse a hue time string
 * @param {object} commandObj the object to parse
 * @return {object} commandObject with values
 */
function parseHueCommandObject(pObj) {
    var commandObj = {};
    commandObj.valid = true;
    
    if(!pObj) {
        dbgPrint("Empty Object, invalid");
        commandObj.valid = false;
        return commandObj;
    }
    try {
        var method = pObj.method;
        // We only support PUT for now
        if(method != "PUT") {
            commandObj.valid = false;
            return commandObj;
        }
        
        var addr = pObj.address;
        var sAddr = addr.split("/")
        // For now we also allow editing schedules created for someone else. 
        // if that is not wanted, sAddr[2] has to be compared against
        // plasmoid.configuration.authToken
        var type = sAddr[3]
        commandObj.group = (type == "groups")
        var target = sAddr[4];
        commandObj.targetId = target;
        
        var body = pObj.body;
        
        // For loop is needed to see if there are additional values we don't support. 
        // In this case we mark the object as invalid, so that the editor preserves
        // the original values and they aren't lost on saving.
        for(var currentItem in body) {
            if(currentItem == "on") {
                commandObj.on = body.on;
            }
            else if(currentItem == "bri") {
                commandObj.bri = body.bri;
            }
            else if(currentItem == "hue") {
                commandObj.hue = body.hue;
            }
            else if(currentItem == "sat") {
                commandObj.sat = body.sat;
            }
            else if(currentItem == "ct") {
                commandObj.ct = body.ct;
            }
            else if(currentItem == "transitiontime") {
                commandObj.transitiontime = body.transitiontime;
            }
            else if(currentItem == "alert") {
                commandObj.alert = body.alert;
            }
            else if(currentItem == "effect") {
                commandObj.effect = body.effect;
            }
            else if(currentItem == "colormode") {
                commandObj.colormode = body.colormode;
            }
            else {
                dbgPrint("Got unknown value: " + currentItem);
                commandObj.valid = false;
                return commandObj;
            }
        }
        
        return commandObj;
    }
    catch (e) {
        dbgPrint("Error in parseHueCommandObject: " + e);
        commandObj.valid = false;
        return commandObj;
    }
}

/**
 * Helper to create an array from a bit mask
 * @param {int} intMask: bitmask as integer
 * @return {array} bitMask as array
 */
function arrayFromMask (intMask) {
    if (intMask > 0x7fffffff || intMask < -0x80000000) { 
        dbgPrint("arrayFromMask: out of range"); 
        return [false,false,false,false,false,false,false];
    }
    for (var nShifted = intMask, resultArray = []; nShifted; 
         resultArray.push(Boolean(nShifted & 1)), nShifted >>>= 1);
    for (var i = resultArray.length; i < 7; ++i) {
        resultArray.push(false)
    }
    return resultArray;
}

/**
 * Helper to get the current Hue IP
 * @param {Function} callback callback with two parameters: success {bool} and ip {string}
 */
function getHueIp (callback) {
    var request = new XMLHttpRequest();
    request.onreadystatechange = function () {
        if (request.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        
        if (request.status !== 200) {
            callback(false, "");
            return;
        }
        
        var json = request.responseText;
        var result = JSON.parse(json);
        if(result && result.length > 0) {
            if(result[0].internalipaddress) {
                callback(true, result[0].internalipaddress);
                return;
            }
        }
        callback(false, "");
    }
    request.open("GET", "https://www.meethue.com/api/nupnp");
    request.send();
}

function dbgPrint(msg) {
    print('[Hoppla] ' + msg)
}

function dummyTranslator() {
    var str = i18n("Switch all lights on");
    str = i18n("Switches all reachable lights on");
    str = i18n("Switch all lights off");
    str = i18n("Switches all reachable lights off");
    str = i18n("LightGroup");
}


function Timer() {
    return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root);
}
