/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate.action;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.webkit.JsPromptResult;

import com.pdi.hybridge.HybridgeActionListener;
import com.pdi.hybridge.HybridgeConst;
import com.pdi.hybridge.HybridgeTask;
import com.pdi.hybridge.boilerplate.MainActivity;

import org.json.JSONException;
import org.json.JSONObject;

public class InitTask extends HybridgeTask {

    private static final String TAG = InitTask.class.getSimpleName();
    private JsPromptResult mResult;
    private HybridgeActionListener mHybridgeListener;

    @SuppressWarnings("unused")
    private Context mContext;

    public InitTask(Activity activity) {
        super(activity);
        mContext = activity.getApplicationContext();
    }

    @Override
    protected JSONObject doInBackground(Object... params) {
        final JSONObject json = (JSONObject) params[0];
        mResult = (JsPromptResult) params[1];
        mHybridgeListener = (HybridgeActionListener) params[2];

        try {
            if (json.has(MainActivity.JSON_KEY_INIT)) {
                json.put(HybridgeConst.EVENT_NAME, HybridgeConst.Event.READY);
                mHybridgeListener.onInitHybridge(json);
            }
        } catch (final JSONException e) {
            Log.e(TAG, "Download: Problem with JSON object " + e.getMessage());
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
