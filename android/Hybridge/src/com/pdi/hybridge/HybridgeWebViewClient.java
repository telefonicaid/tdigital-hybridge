/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.pdi.hybridge.HybridgeConst.Event;

import org.json.JSONArray;

public class HybridgeWebViewClient extends WebViewClient {

    protected JSONArray mActions;
    protected JSONArray mEvents;
    protected HybridgeBroadcaster mBroadcast;
    protected WebView mWebview;

    @SuppressLint("DefaultLocale")
    public HybridgeWebViewClient(JsAction[] actions) {
        mActions = new JSONArray();
        for (final JsAction action : actions) {
            this.mActions.put(action.toString().toLowerCase());
        }

        mEvents = new JSONArray();
        final Event[] events = HybridgeConst.Event.values();
        for (final Event event : events) {
            this.mEvents.put(event.getJsName());
        }
    }

    @Override
    public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
        return super.shouldInterceptRequest(view, url);
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        mBroadcast.initJs(view, mActions, mEvents);
    }

    /*
     * (non-Javadoc)
     * 
     * @see android.webkit.WebViewClient#onPageStarted(android.webkit.WebView, java.lang.String,
     * android.graphics.Bitmap)
     */
    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);
        mWebview = view;
        mBroadcast = HybridgeBroadcaster.getInstance(view);
    }

}
