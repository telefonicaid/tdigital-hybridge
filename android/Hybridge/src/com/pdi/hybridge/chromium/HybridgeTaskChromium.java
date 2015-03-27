/**
 * Hybridge
 * (c) Telefonica Digital, 2015 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.chromium;

import android.app.Activity;

import com.pdi.hybridge.HybridgeTask;

import org.json.JSONObject;
import org.xwalk.core.XWalkJavascriptResult;

/**
 * Base Hybridge Chromium task.
 */
public class HybridgeTaskChromium extends HybridgeTask {

    protected XWalkJavascriptResult mResult;
    protected HybridgeActionListener mHybridgeListener;

    /**
     * Base constructor for Hybridge Chromium tasks.
     */
    public HybridgeTaskChromium(Activity activity) {
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
        mResult = (XWalkJavascriptResult) params[1];
        mHybridgeListener = (HybridgeActionListener) params[2];
        return mJsonMessage;
    }

    /**
     * Default post-execute action.
     */
    @Override
    protected void onPostExecute(JSONObject json) {
        mResult.confirmWithResult(json.toString());
    }
}
