/**
 * Hybridge
 * (c) Telefonica Digital, 2015 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate.webview;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import com.pdi.hybridge.HybridgeConst;
import com.pdi.hybridge.HybridgeConst.Event;
import com.pdi.hybridge.boilerplate.JsActionImpl;
import com.pdi.hybridge.webview.HybridgeBroadcaster;
import com.pdi.hybridge.webview.HybridgeWebChromeClient;
import com.pdi.hybridge.webview.HybridgeWebViewClient;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Observable;
import java.util.Observer;

public class MainActivity extends Activity implements Observer {

    private String mTag = "MainActivity";
    private WebView mWebView;
    private HybridgeBroadcaster mHybridge;

    // String keys for JSON data user in Hybridge communication
    public static final String JSON_KEY_INIT = "initialized";

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mWebView = (WebView) findViewById(R.id.webview);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.setWebViewClient(webViewClient);
        mWebView.setWebChromeClient(webChromeClient);
        mHybridge = HybridgeBroadcaster.getInstance(mWebView);

        // Load the HTML file from local resources
        mWebView.loadUrl("file:///android_asset/hybridge.html");

        // Alternatively you can set the URL of your web app:
        // --> mWebView.load("http://HOST:PORT/hybridge.html");
    }

    private JSONObject getCustomDataObject() {
        final JSONObject customData = new JSONObject();
        try {
            customData.put("a_custom_data", 123456);
        } catch (final JSONException e) {
            Log.e(mTag, "Problem with JSON custom data object " + e.getMessage());
        }
        return customData;
    }

    private final HybridgeWebViewClient webViewClient = new HybridgeWebViewClient(
            JsActionImpl.values(), getCustomDataObject());

    private final WebChromeClient webChromeClient = new HybridgeWebChromeClient(
            JsActionImpl.values());

    @Override
    public void update(Observable observable, Object data) {
        final JSONObject json = (JSONObject) data;
        if (json.has(HybridgeConst.EVENT_NAME)) {
            try {
                mHybridge.fireJavascriptEvent(mWebView, (Event) json.get(HybridgeConst.EVENT_NAME),
                        json);
            } catch (final JSONException e) {
                Log.e(mTag, "Problem with JSON object " + e.getMessage());
            }
        } else {
            mHybridge.fireMessage(mWebView, json);
        }
    }

    /**
     * Callback invoke once the fragment is created.
     * 
     * @see android.app.Fragment#onResume()
     */
    @Override
    public void onResume() {
        mHybridge.addObserver(this);
        super.onResume();
    }

    @Override
    public void onPause() {
        mHybridge.deleteObserver(this);
        super.onPause();
    }
}
