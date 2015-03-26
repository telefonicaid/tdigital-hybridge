
package com.pdi.hybridge.webview;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.webkit.JsPromptResult;

import org.json.JSONObject;

/**
 * Base Hybridge task.
 */
public class HybridgeTaskWebview extends AsyncTask<Object, Void, JSONObject> {

    private static final String TAG = HybridgeTaskWebview.class.getSimpleName();

    protected Context mContext;
    protected JSONObject mJson;
    protected JsPromptResult mResult;
    protected HybridgeBroadcaster mHybridge;

    /**
     * Base constructor for Hybridge tasks.
     */
    public HybridgeTaskWebview(Activity activity) {
        mContext = activity.getApplicationContext();
    }

    /**
     * Helper method to set up the appropriate properties of a HybridgeTask.
     * 
     * @param params
     */
    protected void prepareForBackgroundTask(Object... params) {
        mJson = (JSONObject) params[0];
        mResult = (JsPromptResult) params[1];
        mHybridge = (HybridgeBroadcaster) params[2];
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
        mResult.confirm(json.toString());
    }
}
