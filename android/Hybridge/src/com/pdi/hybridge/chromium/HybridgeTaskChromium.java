
package com.pdi.hybridge.chromium;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import org.json.JSONObject;
import org.xwalk.core.XWalkJavascriptResult;

/**
 * Base Hybridge task.
 */
public class HybridgeTaskChromium extends AsyncTask<Object, Void, JSONObject> {

    private static final String TAG = HybridgeTaskChromium.class.getSimpleName();

    protected Context mContext;
    protected JSONObject mJson;
    protected XWalkJavascriptResult mResult;
    protected HybridgeActionListener mHybridgeListener;

    /**
     * Base constructor for Hybridge tasks.
     */
    public HybridgeTaskChromium(Activity activity) {
        mContext = activity.getApplicationContext();
    }

    /**
     * Helper method to set up the appropriate properties of a HybridgeTask.
     * 
     * @param params
     */
    protected void prepareForBackgroundTask(Object... params) {
        mJson = (JSONObject) params[0];
        mResult = (XWalkJavascriptResult) params[1];
        mHybridgeListener = (HybridgeActionListener) params[2];
    }

    /**
     * Default background task to be performed.
     * 
     * @see android.os.AsyncTask#doInBackground(java.lang.Object[])
     */
    @Override
    protected JSONObject doInBackground(Object... params) {
        prepareForBackgroundTask(params);
        try {
            // Override to do anything.
        } catch (final Exception e) {
            Log.e(TAG, "Problem with JSON object " + e.getMessage());
        }

        return mJson;
    }

    /**
     * Default post-execute action.
     */
    @Override
    protected void onPostExecute(JSONObject json) {
        mResult.confirmWithResult(json.toString());
    }
}
