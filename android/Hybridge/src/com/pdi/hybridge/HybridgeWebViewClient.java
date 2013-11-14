/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge;

import org.json.JSONArray;

import android.annotation.SuppressLint;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.pdi.hybridge.HybridgeConst.Event;

public class HybridgeWebViewClient extends WebViewClient {

    protected JSONArray actions;
    protected JSONArray events;
    protected HybridgeBroadcaster broadcast;

    @SuppressLint("DefaultLocale")
    public HybridgeWebViewClient(JsAction[] actions) {	
        this.actions = new JSONArray();
        for (JsAction action : actions) {
            this.actions.put(action.toString().toLowerCase());
        }

        this.events = new JSONArray();
        Event[] events = HybridgeConst.Event.values();
        for (Event event : events) {
            this.events.put(event.getJsName());
        }
        this.broadcast = HybridgeBroadcaster.getInstance();
    }

    @Override
    public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
        return super.shouldInterceptRequest(view, url);
    }

    @Override  
    public void onPageFinished(WebView view, String url) {
        this.broadcast.initJs(view, actions, events);  
    }

}
