/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.pdi.hybridge.HybridgeActionListener;
import com.pdi.hybridge.HybridgeXWalkView;

import org.json.JSONObject;
import org.xwalk.core.XWalkPreferences;

public class MainActivity extends Activity implements HybridgeActionListener {

    private static final String TAG = MainActivity.class.getSimpleName();

    private HybridgeXWalkView mWebView;

    // String keys for JSON data user in Hybridge communication
    public static final String JSON_KEY_INIT = "initialized";

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        XWalkPreferences.setValue(XWalkPreferences.REMOTE_DEBUGGING, true);

        mWebView = (HybridgeXWalkView) findViewById(R.id.webview);
        // mWebView.setJsActions(JsActionImpl.values());
        // Set the URL of your web app
        // mWebView.load("http://10.95.230.237:8000/hybridge.html", null);
        mWebView.loadAppFromManifest("file:///android_asset/manifest.json", null);
    }

    /**
     * Callback invoke once the fragment is created.
     * 
     * @see android.app.Fragment#onResume()
     */
    @Override
    public void onResume() {
        // mHybridge.addObserver(this);
        super.onResume();
    }

    @Override
    public void onPause() {
        // mHybridge.deleteObserver(this);
        super.onPause();
    }

    /**
     * HybridgeActionListener implementation.
     */
    @Override
    public void onInitHybridge(JSONObject data) {
        Log.d(TAG, "onInitHybridge: " + data.toString());
    }

    @Override
    public void onLoadError(int arg0, String arg1, String arg2) {
        // Do nothing.
    }
}
