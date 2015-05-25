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
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
        document.addEventListener('moca.dataready', this.onMocaDataReady, false);
        document.addEventListener('moca.enterbeacon', this.onEnterBeacon, false);
        document.addEventListener('moca.exitbeacon', this.onExitBeacon, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
        app.updateVersion ('calling version');
        var mocaVersion = MOCA.version (function (mocaVersion) {
            console.log('MOCA Version: ' + mocaVersion);
            app.updateVersion (mocaVersion);
            var proximityEnabled = MOCA.proximityEnabled (function (fEnabled) {
                      console.log('MOCA Proximity: ' + fEnabled);
                      app.updateProximityButton (fEnabled);
            });
        });
    },
    // Called each time MOCA updates proximity data (beacon registry, campaigns)
    onMocaDataReady : function(data) {
        console.log ('MOCA data is ready');
        if (data && data.beacons) {
            for (var i=0; i<data.beacons.length; ++i) {
                var b = data.beacons[i];
                console.log ('Beacon ID' + b.identifier + ', Name: ' + b.name);
            }
        }
    },
    onEnterBeacon: function (e) {
        console.log(e);
        console.log(e.detail);
        app.updateLastEvent ('Enter beacon ' + e.detail.name);
        //document.body.innerHTML += ('<p>Enter beacon ' + e.name + '</p>');
    },
    onExitBeacon: function (e) {
        console.log(e);
        console.log(e.detail);
        app.updateLastEvent ('Exit beacon ' + e.detail.name);
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    },
    updateLastEvent : function (text) {
        var el = document.getElementById('lastevent');
        el.innerHTML = text;
    },
    updateVersion : function (text) {
        var el = document.getElementById('version');
        el.innerHTML = text;
    },

    proximityClickHandler : function () {

        var fEnabled = app.fEnabled;
        if (fEnabled===null) return;
        //alert('inside click handler: ' + fEnabled);
        var el = document.getElementById('proximityBtn');
        if (fEnabled) {
            el.setAttribute('value', 'Stopping proximity...');
            app.fEnabled = null;
            MOCA.setProximityEnabled (false, function () {
                 setTimeout(function() { 
                     el.setAttribute('value', 'Re-start proximity');
                     app.fEnabled = false;
                 }, 3000);                    
            });
        } else {            
            el.setAttribute('value', 'Starting proximity...'); 
            app.fEnabled = null;
            MOCA.setProximityEnabled (true, function () {
                 setTimeout(function() { 
                     el.setAttribute('value', 'Stop proximity');
                     app.fEnabled = true;
                 }, 3000);                    
            });
        }        
    },

    updateProximityButton : function (fEnabled) {
        var el = document.getElementById('proximityBtn');
        el.setAttribute('style', 'display:block;');
        el.setAttribute('value', fEnabled ? 'Stop proximity' : 'Start proximity');
        app.fEnabled = fEnabled;
        if (!app.clickHandler) {
            el.addEventListener ('click', app.proximityClickHandler, false);
            app.clickHandler = true;
        }
    }
     
};

app.initialize();