/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge;

import android.annotation.SuppressLint;
import android.os.AsyncTask;
import android.util.Log;
import android.webkit.WebView;
import android.webkit.WebView.HitTestResult;

import com.pdi.hybridge.HybridgeConst.Event;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Observable;
import java.util.Observer;

public class HybridgeBroadcaster extends Observable {

    private static HybridgeBroadcaster instance;

    private boolean isInitialized = false;

    private final String TAG = "HybridgeBroadcaster";

    private StringBuffer jsBuffer;

    private HashMap<Integer, AsyncTask<JSONObject, Void, JSONObject>> currents;

    @SuppressLint("UseSparseArrays")
    public HybridgeBroadcaster() {
        currents = new HashMap<Integer, AsyncTask<JSONObject, Void, JSONObject>>();
        jsBuffer = new StringBuffer("");
    }

    public static HybridgeBroadcaster getInstance() {
        if (instance == null) {
            instance = new HybridgeBroadcaster();
        }
        return instance;
    }

    public void initJs(WebView view, JSONArray actions, JSONArray events) {
        runJsInWebView(view, "window.HybridgeGlobal || setTimeout(function () {"
                + "window.HybridgeGlobal = {" + //
                "  isReady : true" + //
                ", version : " + HybridgeConst.VERSION + //
                ", actions : " + actions.toString() + //
                ", events : " + events.toString() + //
                "};" //
                + "window.$ && $('#hybridgeTrigger').toggleClass('switch');" + //
                "},0)" //
        );
        isInitialized = true;
    }

    public void firePause(WebView view) {
        final HybridgeConst.Event event = HybridgeConst.Event.PAUSE;
        notifyObservers(event);
        fireJavascriptEvent(view, event, null);
    }

    public void fireResume(WebView view) {
        final HybridgeConst.Event event = HybridgeConst.Event.RESUME;
        notifyObservers(event);
        fireJavascriptEvent(view, event, null);
    }

    public void fireMessage(WebView view, JSONObject data) {
        final HybridgeConst.Event event = HybridgeConst.Event.MESSAGE;
        notifyObservers(event);
        fireJavascriptEvent(view, event, data);
    }

    public void fireReady(WebView view, JSONObject data) {
        final HybridgeConst.Event event = HybridgeConst.Event.READY;
        notifyObservers(event);
        fireJavascriptEvent(view, event, data);
    }

    public void fireJavascriptEvent(final WebView view, final Event event, final JSONObject data) {
        if (isInitialized) {
            view.post(new Runnable() {
                @Override
                public void run() {
                    final WebView.HitTestResult hitTestResult = view.getHitTestResult();
                    String prejs = "";
                    final String json = data != null ? data.toString() : "{}";
                    final StringBuffer js = new StringBuffer("HybridgeGlobal.fireEvent(\"");
                    js.append(event.getJsName()).append("\",").append(json).append(");");

                    if (hitTestResult == null
                            || hitTestResult.getType() != HitTestResult.EDIT_TEXT_TYPE) {
                        if (jsBuffer.length() != 0) {
                            prejs = jsBuffer.append(js.toString()).toString();
                            runJsInWebView(view, prejs);
                            jsBuffer = new StringBuffer("");
                        } else {
                            runJsInWebView(view, js.toString());
                        }
                    } else {
                        Log.d(TAG, "Defer javascript message, user is entering text");
                        jsBuffer.append(js.toString());
                    }
                }
            });
        }
    }

    public void runJsInWebView(WebView view, final String js) {
        view.loadUrl("javascript:(function(){" + js + "})()");
    }

    public void updateState(JSONObject data) {
        this.setChanged();
        this.notifyObservers(data);
        Log.d(TAG, data.toString());
    }

    @SuppressWarnings("unchecked")
    @Override
    public void addObserver(Observer observer) {
        super.addObserver(observer);
        final Class<?> clazz = observer.getClass().getSuperclass();
        if (clazz != null && clazz == android.os.AsyncTask.class) {
            final int hashCode = observer.hashCode();
            final AsyncTask<JSONObject, Void, JSONObject> current = currents.get(hashCode);
            if (current != null) {
                if (current.cancel(true)) {
                    currents.remove(hashCode);
                }
            }
            currents.put(hashCode, (AsyncTask<JSONObject, Void, JSONObject>) observer);
        }
    }

    @Override
    public void deleteObserver(Observer observer) {
        super.deleteObserver(observer);
        final Class<?> clazz = observer.getClass().getSuperclass();
        if (clazz != null && clazz == android.os.AsyncTask.class) {
            final int hashCode = observer.hashCode();
            currents.remove(hashCode);
        }
    }

    /**
     * Indicates that <code>initJs</code> method has been already called. That doesn't means the
     * Hybridge is correctly working, only that the URL has been loaded in the WebView.
     * 
     * @return the boolean flag <code>isInitialized</code>
     */
    public boolean isInitialized() {
        return isInitialized;
    }
}
