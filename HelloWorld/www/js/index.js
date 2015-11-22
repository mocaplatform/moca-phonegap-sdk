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
        MOCA.addEnterBeaconListener(onEnterBeacon);
        MOCA.addExitBeaconListener(onExitBeacon);
        MOCA.addBeaconProximityChangeListener(onBeaconProximityChange);
        MOCA.addEnterPlaceListener(onEnterPlace);
        MOCA.addExitPlaceListener(onExitPlace);
        MOCA.addEnterZoneListener(onEnterZone);
        MOCA.addExitZoneListener(onExitZone);

        MOCA.displayAlert(false, displayAlert);
        MOCA.openUrl(false, openUrl);
        MOCA.showEmbeddedHtml(false, showEmbeddedHtml);
        MOCA.playVideo(false, playVideo);
        MOCA.showImage(false, showImage);
        MOCA.addPassbook(false, addPassbook);
        MOCA.addTag(addTag);
        MOCA.playSound(false, playSound);
        MOCA.customAction(performCustomAction);
        MOCA.addDataReadyListener(didLoadedBeaconsData);

    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function () {
        app.receivedEvent('deviceready');
        MOCA.getRegionStateforPlaceId("zZtKynOKScqBtFnHJ9JPNA", function (data) {
            console.log("getRegionStateForPlaceId result: " + data);
        });
    },
    onEnterBeacon: function (e) {
        console.log("MOCA On Enter beacon");
        console.log(e.detail);
    },
    onExitBeacon: function (e) {
        console.log(e);
        console.log("Event On exit beacon with detail ");
        console.log(e.detail);

    },
    onBeaconProximityChange: function (e) {
        console.log(e);
        console.log("Event On exit beacon with detail ");
        console.log(e.detail);
    },
    onEnterPlace: function (e) {
        console.log(e);
        console.log("Event On enter place with detail ");
        console.log(e.detail);

    },
    onExitPlace: function (e) {
        console.log(e);
        console.log("Event On exit place with detail ");
        console.log(e.detail);
    },
    performCustomAction: function (e) {
        console.log("Callback Perform custom action on JS ");
        console.log(e.detail);
    },
    displayAlert: function (e) {
        console.log("Callback display alert ");
        console.log(e.detail);
    },
    openUrl: function (e) {
        console.log("Callback open URL");
        console.log(e.detail);
    },
    showEmbeddedHtml: function (e) {
        console.log("Callback showEmbeddedHtml");
        console.log(e.detail);
    },
    playVideo: function (e) {
        console.log("Callback playVideo");
        console.log(e.detail);
    },
    showEmbeddedHtml: function (e) {
        console.log("Callback showEmbeddedHtml");
        console.log(e.detail);
    },
    playVideo: function (e) {
        console.log("callback playVideo");
        console.log(e.detail);
    },
    showImage: function (e) {
        console.log("callback showImage");
        console.log(e.detail);
    },
    addPassbook: function (e) {
        console.log("callback addPassbook");
        console.log(e.detail);
    },
    addTag: function (e) {
        console.log("Tag Added");
    },
    playSound: function (e) {
        console.log("callback playSound");
        console.log(e.detail);
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

app.initialize();