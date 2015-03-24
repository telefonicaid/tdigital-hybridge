/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate.action;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.pdi.hybridge.HybridgeTask;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class GetTimeTask extends HybridgeTask {

    private static final String TAG = GetTimeTask.class.getSimpleName();
    @SuppressWarnings("unused")
    private Context mContext;

    public GetTimeTask(Activity activity) {
        super(activity);
        mContext = activity.getApplicationContext();
    }

    @Override
    protected JSONObject doInBackground(Object... params) {
        final JSONObject json = prepareForBackgroundTask(params);

        try {
            final SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss", Locale.ROOT);
            final String time = sdf.format(new Date());
            json.put("time", time);
        } catch (final JSONException e) {
            Log.e(TAG, "Problem with JSON object " + e.getMessage());
        }

        return json;
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
    }

}
