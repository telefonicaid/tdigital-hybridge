/**
 * Hybridge
 * (c) Telefonica Digital, 2015 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Base Hybridge task.
 */
public class HybridgeTask extends AsyncTask<Object, Void, JSONObject> {

    protected Context mContext;
    protected JSONObject mJsonMessage;
    protected JSONObject mJsonData;

    /**
     * Base constructor for Hybridge tasks.
     */
    public HybridgeTask(Activity activity) {
        mContext = activity.getApplicationContext();
    }

    /**
     * Default background task to be performed.
     * 
     * @see android.os.AsyncTask#doInBackground(java.lang.Object[])
     */
    @Override
    protected JSONObject doInBackground(Object... params) {
        try {
            mJsonMessage = (JSONObject) params[0];
            mJsonData = mJsonMessage.getJSONObject(HybridgeConst.JSON_DATA);
        } catch (final JSONException e) {
            e.printStackTrace();
        }
        return mJsonMessage;
    }

}
