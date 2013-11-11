package com.pdi.hybridge.boilerplate.action;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.webkit.JsPromptResult;

import com.pdi.hybridge.HybridgeBroadcaster;
import com.pdi.hybridge.HybridgeConst;
import com.pdi.hybridge.boilerplate.MainActivity;

public class InitTask extends AsyncTask<Object, Void, JSONObject> {

    private final String mTag = "InitTask";
    private JsPromptResult result;
    private Context context;

    public InitTask(Activity activity) {
        this.context = activity.getApplicationContext();
    }

    @Override
    protected JSONObject doInBackground(Object... params) {
        JSONObject json = (JSONObject) params[0];
        result = (JsPromptResult) params[1];

        try {
            if (json.has(MainActivity.JSON_KEY_INIT)) {
                json.put(HybridgeConst.EVENT_NAME, HybridgeConst.Event.READY);
                HybridgeBroadcaster.getInstance().updateState(json);
            }
        } catch (JSONException e) {
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
        result.confirm(json.toString());
    }

}