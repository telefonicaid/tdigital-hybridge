/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import com.pdi.hybridge.HybridgeBroadcaster;
import com.pdi.hybridge.HybridgeConst;
import com.pdi.hybridge.HybridgeConst.Event;
import com.pdi.hybridge.HybridgeWebChromeClient;
import com.pdi.hybridge.HybridgeWebViewClient;

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
        // Set the URL of your web app
        mWebView.loadUrl("http://192.168.1.40/hybridge.html");
    }

    private JSONObject getCustomObject() {
        JSONObject custom = new JSONObject();
        try {
            custom.put("a_custom_data", 123456);
        } catch (JSONException e) {
            Log.e(mTag, "Problem with JSON custom object " + e.getMessage());
        }
        return custom;
    }

    private final HybridgeWebViewClient webViewClient = new HybridgeWebViewClient(
            JsActionImpl.values(), getCustomObject());

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
