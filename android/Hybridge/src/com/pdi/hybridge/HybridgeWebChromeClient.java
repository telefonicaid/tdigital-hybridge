package com.pdi.hybridge;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.os.AsyncTask;
import android.webkit.JsPromptResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import com.pdi.enjoy.lib.utils.Log;

public abstract class HybridgeWebChromeClient extends WebChromeClient {

    protected String mTag = "HybridgeWebChromeClient";
 
    protected abstract JsAction getAction(String action);
    
	@Override
	public final boolean onJsPrompt (WebView view, String url, String msg, String defValue, JsPromptResult result) {
    	String action = msg;
    	JSONObject json = null;
    	Log.v(mTag, "Hybridge action: " + action);
    	try {
			json = new JSONObject(defValue);
			Log.v(mTag, "JSON parsed (Action " + action + ") : " + json.toString());
			executeJSONTask(action, json, result);
		} catch (JSONException e) {
			result.cancel();
			Log.e(mTag, e.getMessage());
		}
    	return true;
    }
	
	@SuppressLint("DefaultLocale")
	@SuppressWarnings({ "unchecked", "rawtypes" })
	private void executeJSONTask(String action, JSONObject json, JsPromptResult result) {
		//JsAction type = JsAction.valueOf(action.toUpperCase());
		JsAction type = getAction(action.toUpperCase());
    	Class clazz = (Class) type.getTask();
    	AsyncTask task = null;
		try {
			task = ((AsyncTask<JSONObject, Void, JSONObject>) clazz.newInstance());
		} catch (InstantiationException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		}
    	task.execute(json, result);
    }
}
