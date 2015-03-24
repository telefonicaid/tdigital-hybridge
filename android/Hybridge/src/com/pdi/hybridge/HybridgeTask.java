
package com.pdi.hybridge;

import android.app.Activity;
import android.os.AsyncTask;
import android.util.Log;

import org.json.JSONObject;
import org.xwalk.core.XWalkJavascriptResult;

/**
 * Base Hybridge task.
 */
public class HybridgeTask extends AsyncTask<Object, Void, JSONObject> {

    private static final String TAG = HybridgeTask.class.getSimpleName();

    protected XWalkJavascriptResult mResult;
    protected HybridgeActionListener mHybridgeListener;

    /**
     * Base constructor for Hybridge tasks.
     * 
     * @param activity
     */
    public HybridgeTask(Activity activity) {

    }

    /**
     * Helper method to set up the appropriate properties of a HybridgeTask.
     * 
     * @param params
     * @return
     */
    protected JSONObject prepareForBackgroundTask(Object... params) {
        final JSONObject json = (JSONObject) params[0];
        mResult = (XWalkJavascriptResult) params[1];
        mHybridgeListener = (HybridgeActionListener) params[2];
        return json;
    }

    /**
     * Default background task to be performed.
     * 
     * @see android.os.AsyncTask#doInBackground(java.lang.Object[])
     */
    @Override
    protected JSONObject doInBackground(Object... params) {
        final JSONObject json = prepareForBackgroundTask(params);
        try {
            // Overrite to do anything.
        } catch (final Exception e) {
            Log.e(TAG, "Problem with JSON object " + e.getMessage());
        }

        return json;
    }

    /**
     * Default post-exetute action.
     */
    @Override
    protected void onPostExecute(JSONObject json) {
        mResult.confirmWithResult(json.toString());
    }
}
