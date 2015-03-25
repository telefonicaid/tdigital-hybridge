/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate.action;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.util.Log;

import com.pdi.hybridge.HybridgeTask;

import org.json.JSONException;
import org.json.JSONObject;

public class GetBatteryTask extends HybridgeTask {

    private static final String TAG = GetBatteryTask.class.getSimpleName();
    private Context mContext;

    public GetBatteryTask(Activity activity) {
        super(activity);
        mContext = activity.getApplicationContext();
    }

    @Override
    protected JSONObject doInBackground(Object... params) {
        final JSONObject json = prepareForBackgroundTask(params);

        try {
            json.put("battery", getBatteryLevel() + "%");
        } catch (final JSONException e) {
            Log.e(TAG, "Problem with JSON object " + e.getMessage());
        }

        return json;
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
    }

    private float getBatteryLevel() {
        final Intent batteryIntent =
                mContext.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        final int level = batteryIntent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        final int scale = batteryIntent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        return ((float) level / (float) scale) * 100.0f;
    }

}
