/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.AsyncTask;
import android.util.Log;
import android.webkit.JsPromptResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;

public class HybridgeWebChromeClient extends WebChromeClient {

    protected String mTag = "HybridgeWebChromeClient";

    @SuppressWarnings("rawtypes")
    protected HashMap<String, Class> mActions;

    @SuppressWarnings("rawtypes")
    @SuppressLint("DefaultLocale")
    public HybridgeWebChromeClient(JsAction[] actions) {
        mActions = new HashMap<String, Class>(actions.length);
        for (final JsAction action : actions) {
            mActions.put(action.toString().toLowerCase(), action.getTask());
        }
    }

    @Override
    public final boolean onJsPrompt(WebView view, String url, String msg, String defValue,
            JsPromptResult result) {
        final String action = msg;
        JSONObject json = null;
        Log.v(mTag, "Hybridge action: " + action);
        try {
            json = new JSONObject(defValue);
            Log.v(mTag, "JSON parsed (Action " + action + ") : " + json.toString());
            executeJSONTask(action, json, result, HybridgeBroadcaster.getInstance(view),
                    (Activity) view.getContext());
        } catch (final JSONException e) {
            result.cancel();
            Log.e(mTag, e.getMessage());
        }
        return true;
    }

    @SuppressLint("DefaultLocale")
    @SuppressWarnings({
            "unchecked", "rawtypes"
    })
    private void executeJSONTask(String action, JSONObject json, JsPromptResult result,
            HybridgeBroadcaster hybridge, Activity activity) {
        final Class clazz = mActions.get(action);
        if (clazz != null && hybridge != null) {
            AsyncTask task = null;
            try {
                task =
                        (AsyncTask<JSONObject, Void, JSONObject>) clazz.getDeclaredConstructor(
                                new Class[] {
                                    android.app.Activity.class
                                }).newInstance(activity);
            } catch (final InstantiationException e) {
                e.printStackTrace();
            } catch (final IllegalAccessException e) {
                e.printStackTrace();
            } catch (final IllegalArgumentException e) {
                e.printStackTrace();
            } catch (final InvocationTargetException e) {
                e.printStackTrace();
            } catch (final NoSuchMethodException e) {
                e.printStackTrace();
            }
            Log.v(mTag, "Execute action " + action);
            task.execute(json, result, hybridge);
        } else {
            result.confirm(json.toString());
            Log.d(mTag, "Hybridge action not implemented: " + action);
        }
    }
}
