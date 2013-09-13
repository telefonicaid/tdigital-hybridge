package com.pdi.hybridgedemo;

import org.json.JSONException;
import org.json.JSONObject;

import com.pdi.hybridge.JsAction;


import android.os.AsyncTask;
import android.webkit.JsPromptResult;

@SuppressWarnings("rawtypes")
public enum JsActionImpl implements JsAction {

	PRODUCT(ProductTask.class),
	DOWNLOAD(DownloadTask.class),
	PLAY(PlayTask.class);
	
	private Class task;
	
	JsActionImpl(Class task) {
		this.setTask(task);
	}
	
    public Class getTask() {
		return task;
	}

	public void setTask(Class task) {
		this.task = task;
	}

	public static class ProductTask extends AsyncTask <Object, Void, JSONObject> {
    	private JsPromptResult result;
    	
    	public ProductTask() {}
    	
        protected JSONObject doInBackground(Object... params) {
        	result = (JsPromptResult) params[1];
        	JSONObject json = (JSONObject) params[0];
        	try {
				json.put("downloaded", 100);
			} catch (JSONException e) {
				e.printStackTrace();
			}
        	return json;
        }

        protected void onPreExecute() {
        }
        
        protected void onProgressUpdate(Void... progress) {
        }

        protected void onPostExecute(JSONObject json) {
        	result.confirm(json.toString());
        }
    }
    
	public static class DownloadTask extends AsyncTask <Object, Integer, JSONObject> {
    	private JsPromptResult result;
    	
    	public DownloadTask() {}
    	
        protected JSONObject doInBackground(Object... params) {
        	result = (JsPromptResult) params[1];
        	JSONObject json = (JSONObject) params[0];
        	return json;
        }

        protected void onPreExecute() {
        }
        
        protected void onProgressUpdate(Integer... progress) {
        }

        protected void onPostExecute(JSONObject json) {
        	result.confirm(json.toString());
        }
    }
    
	public static class PlayTask extends AsyncTask <Object, Void, JSONObject> {
    	private JsPromptResult result;
    	
    	public PlayTask() {}
    	
        protected JSONObject doInBackground(Object... params) {
        	result = (JsPromptResult) params[1];
        	JSONObject json = (JSONObject) params[0];
        	return json;
        }

        protected void onPreExecute() {
        }
        
        protected void onProgressUpdate(Void... progress) {
        }

        protected void onPostExecute(JSONObject json) {
        	result.confirm(json.toString());
        }
    }
	
}
