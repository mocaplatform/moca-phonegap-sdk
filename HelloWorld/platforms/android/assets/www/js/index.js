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
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    },
    updateVersion : function (text) {
        var el = document.getElementById('version');
        el.innerHTML = text;
    },
    updateProximityButton : function (fEnabled) {
        var el = document.getElementById('proximityBtn');
        el.setAttribute('style', 'display:block;');
        el.setAttribute('value', fEnabled ? 'Stop proximity' : 'Start proximity');
        if (fEnabled) {
            el.addEventListener('click', function () {
                alert('Toogle clicked');
                MOCA.setProximityEnabled (true, function () {
                     alert('Proximity enabled');
                });
            }, false);
            alert('Toogle on installed');
        } else {
            el.addEventListener('click', toogleProximityOff, false);
        }
    },
    toogleProximityOn : function () {
        MOCA.setProximityEnabled (true, function () {
              alert('Proximity enabled');
        });
    },
    toogleProximityOff : function () {
        MOCA.setProximityEnabled (false, function () {
              alert('Proximity disabled');
        });
    }
};

app.initialize();