/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge;

import android.util.Log;
import android.util.SparseArray;
import android.webkit.WebView;
import android.webkit.WebView.HitTestResult;

import com.pdi.hybridge.HybridgeConst.Event;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.Observable;
import java.util.Observer;

public class HybridgeBroadcaster extends Observable {

    private static SparseArray<HybridgeBroadcaster> mClients =
            new SparseArray<HybridgeBroadcaster>();

    private boolean mIsInitialized = false;

    private WebView mClient;

    private final String TAG = "HybridgeBroadcaster";

    private StringBuffer mJsBuffer;

    private SparseArray<WebView> mCurrents;

    public HybridgeBroadcaster(WebView client) {
        mClient = client;
        mCurrents = new SparseArray<WebView>();
        mJsBuffer = new StringBuffer("");
    }

    public static HybridgeBroadcaster getInstance(WebView client) {
        final int hash = client.hashCode();
        HybridgeBroadcaster instance = mClients.get(hash);
        if (instance == null) {
            instance = new HybridgeBroadcaster(client);
            mClients.put(hash, instance);
        }
        return instance;
    }

    public void initJs(WebView view, JSONArray actions, JSONArray events) {
        runJsInWebView(view, "window.HybridgeGlobal || setTimeout(function () {"
                + "window.HybridgeGlobal = {" + "  isReady : true" + ", version : "
                + HybridgeConst.VERSION + ", actions : " + actions.toString() + ", events : "
                + events.toString() + "};"
                + "window.$ && $('#hybridgeTrigger').toggleClass('switch');" + "},0)");
        mIsInitialized = true;
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
        if (mIsInitialized) {
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
                        if (mJsBuffer.length() != 0) {
                            prejs = mJsBuffer.append(js.toString()).toString();
                            runJsInWebView(view, prejs);
                            mJsBuffer = new StringBuffer("");
                        } else {
                            runJsInWebView(view, js.toString());
                        }
                    } else {
                        Log.d(TAG, "Defer javascript message, user is entering text");
                        mJsBuffer.append(js.toString());
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

    @Override
    public void addObserver(Observer observer) {
        super.addObserver(observer);
        /*
         * final int hashCode = observer.hashCode(); final WebView current =
         * mCurrents.get(hashCode); if (current == null) { mCurrents.put(hashCode, (WebView)
         * observer); }
         */
    }

    @Override
    public void deleteObserver(Observer observer) {
        super.deleteObserver(observer);
        // mCurrents.remove(observer.hashCode());
    }
}
