package com.innoquant.moca.phonegap;

import com.innoquant.moca.MOCABeacon;
import com.innoquant.moca.MOCAPlace;
import com.innoquant.moca.MOCAZone;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Date;

/**
 * Created by tomacco on 21/11/15.
 */
public class Utils {
    public static JSONObject beaconToJSON(MOCABeacon beacon) throws JSONException {
        if (beacon == null) return null;
        Date date = new Date();
        JSONObject bkn = new JSONObject();
        bkn.put("type", "beacon");
        bkn.put("id", beacon.getId());
        bkn.put("uuid", beacon.getProximityUUID().toString());
        bkn.put("major", beacon.getMajor());
        bkn.put("minor", beacon.getMinor());
        bkn.put("name", beacon.getName());
        bkn.put("proximity", beacon.getProximity().toString());
        bkn.put("timestamp", date.getTime());
        return bkn;
    }
    public static JSONObject placeToJSON(MOCAPlace mocaPlace) throws JSONException{
        if(mocaPlace == null) return null;
        Date date = new Date();
        JSONObject plc = new JSONObject();
        plc.put("type", "place");
        plc.put("name", mocaPlace.getName());
        plc.put("id", mocaPlace.getId());
        JSONObject gfence = new JSONObject();
        gfence.put("lat", mocaPlace.getGeoFence().getCenter().getLatitude());
        gfence.put("lon", mocaPlace.getGeoFence().getCenter().getLongitude());
        gfence.put("accuracy", mocaPlace.getGeoFence().getCenter().getAccuracy());
        plc.put("geofence", gfence);
        plc.put("timestamp", date.getTime());
        return plc;
    }

    public static JSONObject zoneToJSON(MOCAZone mocaZone) throws JSONException{
        if(mocaZone == null) return null;
        Date date = new Date();
        JSONObject zn = new JSONObject();
        zn.put("type", "zone");
        zn.put("id", mocaZone.getId());
        zn.put("name", mocaZone.getName());
        zn.put("timestamp", date.getTime());
        return zn;
    }
}
