/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate;

import java.util.Observable;
import java.util.Observer;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import com.pdi.hybridge.HybridgeBroadcaster;
import com.pdi.hybridge.HybridgeConst;
import com.pdi.hybridge.HybridgeWebChromeClient;
import com.pdi.hybridge.HybridgeWebViewClient;
import com.pdi.hybridge.HybridgeConst.Event;

public class MainActivity extends Activity implements Observer {
    
    private String mTag = "MainActivity";
    private WebView mWebView;
    
    // String keys for JSON data user in Hybridge communication
    public static final String JSON_KEY_INIT = "initialized";
    
    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        HybridgeBroadcaster.getInstance().addObserver(this);
        mWebView = (WebView) findViewById(R.id.webview);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.setWebViewClient(webViewClient);
        mWebView.setWebChromeClient(webChromeClient);
        // Set the URL of your web app
        mWebView.loadUrl("http://localhost/hybridge.html");
    }

    private final HybridgeWebViewClient webViewClient = new HybridgeWebViewClient(JsActionImpl.values());

    private final WebChromeClient webChromeClient = new HybridgeWebChromeClient(JsActionImpl.values());
    
    @Override
    public void update(Observable observable, Object data) {
        JSONObject json = (JSONObject) data;
        if (json.has(HybridgeConst.EVENT_NAME)) {
            try {
                HybridgeBroadcaster.getInstance().fireJavascriptEvent(mWebView, (Event) json.get(HybridgeConst.EVENT_NAME), json);
            } catch (JSONException e) {
                Log.e(mTag, "Problem with JSON object " + e.getMessage());
            }
        } else {
            HybridgeBroadcaster.getInstance().fireMessage(mWebView, json);
        }
    }
}
