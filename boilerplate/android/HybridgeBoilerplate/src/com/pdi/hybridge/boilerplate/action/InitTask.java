/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate.action;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.webkit.JsPromptResult;

import com.pdi.hybridge.HybridgeBroadcaster;
import com.pdi.hybridge.HybridgeConst;
import com.pdi.hybridge.boilerplate.MainActivity;

import org.json.JSONException;
import org.json.JSONObject;

public class InitTask extends AsyncTask<Object, Void, JSONObject> {

    private final String mTag = "InitTask";
    private JsPromptResult mResult;
    private Context mContext;
    private HybridgeBroadcaster mHybridge;

    public InitTask(Activity activity) {
        mContext = activity.getApplicationContext();
    }

    @Override
    protected JSONObject doInBackground(Object... params) {
        final JSONObject json = (JSONObject) params[0];
        mResult = (JsPromptResult) params[1];
        mHybridge = (HybridgeBroadcaster) params[2];

        try {
            if (json.has(MainActivity.JSON_KEY_INIT)) {
                json.put(HybridgeConst.EVENT_NAME, HybridgeConst.Event.READY);
                mHybridge.updateState(json);
            }
        } catch (final JSONException e) {
            Log.e(mTag, "Download: Problem with JSON object " + e.getMessage());
        }

        return json;
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
    }

    @Override
    protected void onPostExecute(JSONObject json) {
        mResult.confirm(json.toString());
    }

}
