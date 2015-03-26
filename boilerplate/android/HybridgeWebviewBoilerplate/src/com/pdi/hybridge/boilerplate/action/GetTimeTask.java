/**
 * Hybridge
 * (c) Telefonica Digital, 2015 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate.action;

import android.app.Activity;
import android.util.Log;

import com.pdi.hybridge.webview.HybridgeTaskWebview;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class GetTimeTask extends HybridgeTaskWebview {

    private static final String TAG = GetTimeTask.class.getSimpleName();

    public GetTimeTask(Activity activity) {
        // You must provide a constructor to pass the current Activity.
        super(activity);
    }

    @Override
    protected JSONObject doInBackground(Object... params) {
        // You must always call super prior to do anything.
        super.doInBackground(params);

        try {
            final SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss", Locale.ROOT);
            final String time = sdf.format(new Date());
            mJson.put("time", time);
        } catch (final JSONException e) {
            Log.e(TAG, "Problem with JSON object " + e.getMessage());
        }

        return mJson;
    }

}
