package com.pdi.hybridge;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.AsyncTask;
import android.webkit.JsPromptResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import com.pdi.enjoy.lib.utils.Log;

public class HybridgeWebChromeClient extends WebChromeClient {

    protected String mTag = "HybridgeWebChromeClient";
 
    @SuppressWarnings("rawtypes")
	protected HashMap<String, Class> actions;
    
	@SuppressWarnings("rawtypes")
	@SuppressLint("DefaultLocale")
	public HybridgeWebChromeClient(JsAction[] actions) {	
		this.actions = new HashMap<String, Class>(actions.length);
		for (JsAction action : actions) {
			this.actions.put(action.toString().toLowerCase(), action.getTask());
		}
	}
    
	@Override
	public final boolean onJsPrompt (WebView view, String url, String msg, String defValue, JsPromptResult result) {
    	String action = msg;
    	JSONObject json = null;
    	Log.v(mTag, "Hybridge action: " + action);
    	try {
			json = new JSONObject(defValue);
			Log.v(mTag, "JSON parsed (Action " + action + ") : " + json.toString());
			executeJSONTask(action, json, result, view.getContext());
		} catch (JSONException e) {
			result.cancel();
			Log.e(mTag, e.getMessage());
		}
    	return true;
    }
	
	@SuppressLint("DefaultLocale")
	@SuppressWarnings({ "unchecked", "rawtypes" })
	private void executeJSONTask(String action, JSONObject json, JsPromptResult result, Context context) {
		Class clazz = this.actions.get(action);
    	AsyncTask task = null;
		try {
			task = (AsyncTask<JSONObject, Void, JSONObject>) 
					clazz.getDeclaredConstructor
					( new Class[] { clazz.getDeclaringClass(), android.content.Context.class } )
					.newInstance(null, context);
			//task = ((AsyncTask<JSONObject, Void, JSONObject>) clazz.getDeclaredConstructor(clazz).newInstance(context));
			//task = ((AsyncTask<JSONObject, Void, JSONObject>) clazz.newInstance());
		} catch (InstantiationException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Log.v(mTag, "Execute action " + action);
    	task.execute(json, result);
    }
}
