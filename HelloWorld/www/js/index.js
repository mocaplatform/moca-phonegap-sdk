/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },
    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        this.receivedEvent('deviceready');
        app.requestMocaPermissions();
    },
    requestMocaPermissions: function() {
        var permissions = cordova.plugins.permissions;
        var onError = function(e) {
            console.error(error, e);
        };
        var onRequestPermissionResult = function(permStatus) {
            permStatus.hasPermission ? app.startProximityServices() : console.warn("Location Permission denied");
        };
        var onPermissionStatus = function(permStatus) {
            if (!permStatus.hasPermission) {
                permissions.requestPermission(permissions.ACCESS_FINE_LOCATION, onRequestPermissionResult, onError);
            } else {
                app.startProximityServices();
            }
        };
        permissions.hasPermission(permissions.ACCESS_FINE_LOCATION, onPermissionStatus, onError);
        app.hookCallbacks();
        console.log("(JAVASCRIPT SIDE) SUBSCRIBED TO MOCA EVENTS.");
        app.testUserAPI();
        app.testInstanceTagAPI();
    },
    testUserAPI: function() {
        console.log("********** START TEST USER TEST **********");
        MOCA.login("fakeemail@anemail.com");
        var instance = MOCA.currentInstance();
        console.log("1. instance Stringifyed:" + JSON.stringify(instance));
        console.log("2. instance id, no callbacks: " + instance.id);
        instance.identifier(function(id) {
            console.log("3. Instance id, with callback deprecated " + id)
        });
        instance.currentUser(function(user) {
            console.log("4. User Object: ");
            console.log(user);
            user.setCustomProperty("jsProp", "isWorking");
            user.customProperty("jsProp", function(prop) {
                console.log("5. should return an object with {jsProp, isWorking}: ")
                console.log(prop);
            });
            console.log("6. user id without callbacks" + user.id);
        });
    },
    testInstanceTagAPI: function() {
        console.log("**********︎ START TEST INSTANCE TAG API TEST **********");
        var instance = MOCA.currentInstance();
        console.log(instance);
        instance.addTag("Verde", "+2");
        instance.addTag("Azul", "=2");
        instance.addTag("Rojo", "-1");
        instance.addTag("Amarillo");
        instance.addTag();
        instance.addTag("gris", 1);
        instance.addTag("negro", "--2");
        console.log("calling containsTag...");
        instance.containsTag("Amarillo", function(isTagContained) {
            if (isTagContained) {
                instance.getTagValue("Amarillo", function(tagValue) {
                    console.log("Amarillo value: -> " + tagValue + " YES IT IS CONTAINED");
                    console.log("now remove the Amarillo tag");
                    instance.removeTag("Amarillo");
                    instance.containsTag("Amarillo", function(isTagContained) {
                        if (isTagContained) {
                            var value = instance.getTagValue("Amarillo");
                            console.log("Amarillo value: -> " + value + " YES IT IS SILL CONTAINED.. BUMMER :-(");
                        } else {
                            console.log("GOOD!, tag has been removed succesfully");
                        }
                    });
                });
            }
        });
    },
    startProximityServices: function() {
        MOCA.setProximityEnabled(true);
        MOCA.setGeoTrackingEnabled(true);
    },
    hookCallbacks: function() {
        MOCA.addEnterPlaceListener(eventListener);
        MOCA.addExitPlaceListener(eventListener);
        MOCA.addEnterZoneListener(eventListener);
        MOCA.addExitZoneListener(eventListener);
        MOCA.addCustomActionListener(eventListener);
        MOCA.addEnterBeaconListener(eventListener);
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');
        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');
        console.log('Received Event: ' + id);
    }
};
var eventListener = function(e) {
    console.error("(JAVASCRIPT SIDE) Received MOCA Event: " + JSON.stringify(e.detail));
}
app.initialize();