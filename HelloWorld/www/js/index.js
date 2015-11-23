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
    initialize: function () {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.


    //TEST 1: test false / true arguments

    bindEvents: function () {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function () {
        app.receivedEvent('deviceready');
        MOCA.addEnterBeaconListener(onEnterBeacon);
        MOCA.addExitBeaconListener(onExitBeacon);
        MOCA.addBeaconProximityChangeListener(onBeaconProximityChange);
        MOCA.addEnterPlaceListener(onEnterPlace);
        MOCA.addExitPlaceListener(onExitPlace);
        MOCA.addEnterZoneListener(onEnterZone);
        MOCA.addExitZoneListener(onExitZone);

        MOCA.addDisplayAlertListener(false, displayAlert);
        MOCA.addOpenUrlListener(false, openUrl);
        MOCA.addShowEmbeddedHtmlListener(false, showEmbeddedHtml);
        MOCA.addPlayVideoListener(false, playVideo);
        MOCA.addShowImageListener(false, showImage);
        MOCA.addAddPassbookListener(false, addPassbook);
        MOCA.addAddTagListener(addTag);
        MOCA.addPlaySoundListener(false, playSound);
        MOCA.addCustomActionListener(performCustomAction);
        MOCA.addDataReadyListener(didLoadedBeaconsData);


        getMOCAValues();
    },
    // Update DOM on a Received Event
    receivedEvent: function (id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

var getMOCAValues = function(){
    MOCA.placesInside(placesInside);
    var ver = document.getElementById("ver");
    var appKey = document.getElementById("appKey");
    var appSecret = document.getElementById("appSecret");
    var logLevel = document.getElementById("logLevel");
    MOCA.version(function(e){ ver.innerHTML = "Native SDK version: <b>" + e +"</b>"});
    MOCA.appKey(function(e){ appKey.innerHTML = "appKey: <b>" + e + "</b>"});
    MOCA.appSecret(function(e){ appSecret.innerHTML = "appSecret: <b>" + e + "</b>"});
    MOCA.logLevel(function(e){ logLevel.innerHTML = "logLevel: <b>" + e + "</b>"});
}

//console.log = function(message) {
//    var logger = document.getElementById("logger");
//    logger.innerHTML = logger.innerHTML + "<li>" + message + "</li>";
//};

var onEnterBeacon= function (e) {
    console.log("MOCA On Enter beacon");
    console.log(e.detail);
};
var onExitBeacon= function (e) {
    console.log("Event On exit beacon with detail ");
    console.log(e.detail);
};
var onEnterZone = function (e) {
    console.log("Event On Enter Zone");
    console.log(e.detail);
};
var onExitZone = function (e) {
    console.log("Event On Exit Zone");
    console.log(e.detail);
};
var onBeaconProximityChange= function (e) {
    console.log(e);
    console.log("Event On Proximity change with detail ");
    console.log(e.detail);
};
var onEnterPlace= function (e) {
    console.log(e);
    console.log("Event On enter place with detail ");
    console.log(e.detail);

};
var onExitPlace= function (e) {
    console.log(e);
    console.log("Event On exit place with detail ");
    console.log(e.detail);
};
var performCustomAction= function (e) {
    console.log("Callback Perform custom action on JS ");
    console.log(e.detail);
};
var displayAlert= function (e) {
    console.log("Callback display alert ");
    console.log(e.detail);
};
var openUrl= function (e) {
    console.log("Callback open URL");
    console.log(e.detail);
};
var showEmbeddedHtml= function (e) {
    console.log("Callback showEmbeddedHtml");
    console.log(e.detail);
};
var playVideo= function (e) {
    console.log("callback playVideo");
    console.log(e.detail);
};
var showImage= function (e) {
    console.log("callback showImage");
    console.log(e.detail);
};
var addPassbook= function (e) {
    console.log("callback addPassbook");
    console.log(e.detail);
};
var addTag= function (e) {
    console.log("Tag Added");
};
var playSound= function (e) {
    console.log("callback playSound");
    console.log(e.detail);
};

var didLoadedBeaconsData = function (e){
    console.log("MOCA data loaded");
    console.log(e.detail);
};

var placesInside = function (e) {
    console.log("places inside: ");
    console.log(e);
};

app.initialize();