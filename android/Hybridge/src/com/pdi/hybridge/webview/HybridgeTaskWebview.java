/**
 * Hybridge
 * (c) Telefonica Digital, 2015 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.webview;

import android.app.Activity;
import android.webkit.JsPromptResult;

import com.pdi.hybridge.HybridgeTask;

import org.json.JSONObject;

/**
 * Base Hybridge Webview task.
 */
public class HybridgeTaskWebview extends HybridgeTask {

    protected JsPromptResult mResult;
    protected HybridgeBroadcaster mHybridge;

    /**
     * Base constructor for Hybridge Webview tasks.
     */
    public HybridgeTaskWebview(Activity activity) {
        super(activity);
    }

    /**
     * Default background task to be performed.
     * 
     * @see android.os.AsyncTask#doInBackground(java.lang.Object[])
     */
    @Override
    protected JSONObject doInBackground(Object... params) {
        super.doInBackground(params);
        mResult = (JsPromptResult) params[1];
        mHybridge = (HybridgeBroadcaster) params[2];
        return mJsonMessage;
    }

    /**
     * Default post-execute action.
     */
    @Override
    protected void onPostExecute(JSONObject json) {
        mResult.confirm(json.toString());
    }
}
