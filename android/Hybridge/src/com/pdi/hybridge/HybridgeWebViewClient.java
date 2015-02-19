/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge;

import android.annotation.SuppressLint;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.pdi.hybridge.HybridgeConst.Event;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class HybridgeWebViewClient extends WebViewClient {

    protected JSONArray mActions;
    protected JSONArray mEvents;
    protected JSONObject mCustom;

    @SuppressLint("DefaultLocale")
    public HybridgeWebViewClient(JsAction[] actions, JSONObject custom) {
        mActions = new JSONArray();
        for (final JsAction action : actions) {
            this.mActions.put(action.toString().toLowerCase());
        }

        mEvents = new JSONArray();
        final Event[] events = HybridgeConst.Event.values();
        for (final Event event : events) {
            this.mEvents.put(event.getJsName());
        }

        try {
            mCustom = new JSONObject(custom.toString());
        } catch (JSONException e) {
            mCustom = new JSONObject();
        }
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);
        final HybridgeBroadcaster hybridge = HybridgeBroadcaster.getInstance(view);
        if (hybridge != null) {
            hybridge.initJs(view, mActions, mEvents, mCustom);
        }
    }
}
