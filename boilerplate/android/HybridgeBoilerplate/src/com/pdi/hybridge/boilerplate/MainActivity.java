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
import android.widget.Toast;

import com.pdi.hybridge.HybridgeActionListener;
import com.pdi.hybridge.HybridgeXWalkView;

import org.json.JSONException;
import org.json.JSONObject;
import org.xwalk.core.XWalkPreferences;

public class MainActivity extends Activity implements HybridgeActionListener {

    private static final String TAG = MainActivity.class.getSimpleName();
    private HybridgeXWalkView mWebView;

    // String keys for JSON data user in Hybridge communication
    public static final String JSON_KEY_INIT = "initialized";

    private static final String TIMESTAMP = "timestamp";

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        XWalkPreferences.setValue(XWalkPreferences.REMOTE_DEBUGGING, true);

        mWebView = (HybridgeXWalkView) findViewById(R.id.webview);
        mWebView.setHybridgeActionListener(this);
        mWebView.setCustomData(getCustomDataObject());
        mWebView.setJsActions(JsActionImpl.values());
        // Set the URL of your web app
        mWebView.load("http://10.95.231.200:8000/hybridge.html", null);
        // Alternatively the app can be loaded from manifest.
        // mWebView.loadAppFromManifest("file:///android_asset/manifest.json", null);
    }

    private JSONObject getCustomDataObject() {
        final JSONObject customData = new JSONObject();
        try {
            customData.put(TIMESTAMP, System.currentTimeMillis());
        } catch (final JSONException e) {
            Log.e(TAG, "Problem with JSON custom data object " + e.getMessage());
        }
        return customData;
    }

    /**
     * Callback invoke once the fragment is created.
     * 
     * @see android.app.Fragment#onResume()
     */
    @Override
    protected void onPause() {
        super.onPause();
        if (mWebView != null) {
            mWebView.pauseTimers();
            mWebView.onHide();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mWebView != null) {
            mWebView.resumeTimers();
            mWebView.onShow();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mWebView != null) {
            mWebView.onDestroy();
        }
    }

    /**
     * HybridgeActionListener implementation.
     */
    @Override
    public void onInitHybridge(JSONObject data) {
        Log.d(TAG, "onInitHybridge:data " + data.toString());
        if (!this.isFinishing()) {
            long start = 0;
            try {
                start = data.getLong(TIMESTAMP);
            } catch (final JSONException e) {
                e.printStackTrace();
            }
            final long finish = System.currentTimeMillis();
            Toast.makeText(this,
                    "Javascript says is ready and it took " + (finish - start) + " ms",
                    Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public void onLoadError(int arg0, String arg1, String arg2) {
        // Do nothing.
    }
}
