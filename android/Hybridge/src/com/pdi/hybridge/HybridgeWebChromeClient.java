/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.AsyncTask;
import android.util.Log;
import android.webkit.JsPromptResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

public class HybridgeWebChromeClient extends WebChromeClient {

    protected String mTag = "HybridgeWebChromeClient";

    @SuppressWarnings("rawtypes")
    protected HashMap<String, Class> actions;

    @SuppressWarnings("rawtypes")
    @SuppressLint("DefaultLocale")
    public HybridgeWebChromeClient(JsAction[] actions) {	
        this.actions = new HashMap<String, Class>(actions.length);
        for (JsAction action : actions) {
            this.actions.put(action.toString().toLowerCase(), action.getTask());
        }
    }

    @Override
    public final boolean onJsPrompt(WebView view, String url, String msg, String defValue, JsPromptResult result) {
        String action = msg;
        JSONObject json = null;
        Log.v(mTag, "Hybridge action: " + action);
        try {
            json = new JSONObject(defValue);
            Log.v(mTag, "JSON parsed (Action " + action + ") : " + json.toString());
            executeJSONTask(action, json, result, (Activity) view.getContext());
        } catch (JSONException e) {
            result.cancel();
            Log.e(mTag, e.getMessage());
        }
        return true;
    }

    @SuppressLint("DefaultLocale")
    @SuppressWarnings({ "unchecked", "rawtypes" })
    private void executeJSONTask(String action, JSONObject json, JsPromptResult result, Activity activity) {
        Class clazz = this.actions.get(action);
        if (clazz != null) {
            AsyncTask task = null;
            try {
                task = (AsyncTask<JSONObject, Void, JSONObject>) 
                        clazz.getDeclaredConstructor
                        ( new Class[] { android.app.Activity.class } )
                        .newInstance(activity);
            } catch (InstantiationException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (IllegalArgumentException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            }
            Log.v(mTag, "Execute action " + action);
            task.execute(json, result);
        } else {
            result.confirm(json.toString());
            Log.d(mTag, "Hybridge action not implemented: " + action);
        }
    }
}
