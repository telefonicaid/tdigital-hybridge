/**
 * Hybridge
 * (c) Telefonica Digital, 2015 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate.action;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.util.Log;

import com.pdi.hybridge.chromium.HybridgeTaskChromium;

import org.json.JSONException;
import org.json.JSONObject;

public class GetBatteryTask extends HybridgeTaskChromium {

    private static final String TAG = GetBatteryTask.class.getSimpleName();

    public GetBatteryTask(Activity activity) {
        // You must provide a constructor to pass the current Activity.
        super(activity);
    }

    @Override
    protected JSONObject doInBackground(Object... params) {
        // You must always call super prior to do anything.
        super.doInBackground(params);

        try {
            mJson.put("battery", getBatteryLevel() + "%");
        } catch (final JSONException e) {
            Log.e(TAG, "Problem with JSON object " + e.getMessage());
        }

        return mJson;
    }

    private float getBatteryLevel() {
        final Intent batteryIntent =
                mContext.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        final int level = batteryIntent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        final int scale = batteryIntent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        return ((float) level / (float) scale) * 100.0f;
    }

}
