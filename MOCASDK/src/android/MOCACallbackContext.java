package com.innoquant.moca.phonegap;


import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;



public class MOCACallbackContext {
    private CallbackContext _context;
    private JSONArray _args;

    public MOCACallbackContext(CallbackContext ctx, JSONArray args) {
        _context = ctx;
        _args = args;
    }

    public void sendPluginResult(PluginResult result){
        _context.sendPluginResult(result);
    }

    public JSONArray getArgs() {
        return _args;
    }
}
