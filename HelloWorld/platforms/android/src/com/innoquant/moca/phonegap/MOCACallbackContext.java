package com.innoquant.moca.phonegap;


import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONArray;


public class MOCACallbackContext {
    private CallbackContext _context;
    private JSONArray _args = new JSONArray();
    private Boolean _returnValue = false;

    public MOCACallbackContext(CallbackContext ctx, JSONArray args) {
        _context = ctx;
        _args = args;
        getBooleanArg(args);
    }

    public void sendPluginResult(PluginResult result){
        _context.sendPluginResult(result);
    }

    public JSONArray getArgs() {
        return _args;
    }

    private void getBooleanArg(JSONArray arr){
        if( arr != null && arr.length() > 0){
            try {
                _returnValue = Boolean.parseBoolean(arr.getString(0));
            }catch (JSONException e){
                _returnValue = false;
            }
        }
    }

    public boolean getReturnValue() {
        return _returnValue;
    }
}
