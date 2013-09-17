package com.pdi.hybridge;

import org.json.JSONArray;

import android.annotation.SuppressLint;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class HybridgeWebViewClient extends WebViewClient {

	protected JSONArray actions;
	
	@SuppressLint("DefaultLocale")
	public HybridgeWebViewClient(JsAction[] actions) {	
		this.actions = new JSONArray();
		for (JsAction action : actions) {
			this.actions.put(action.toString().toLowerCase());
		}
	}
	
    @Override
    public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
        return super.shouldInterceptRequest(view, url);
    }
    
    @Override  
    public void onPageFinished(WebView view, String url) {  
        view.loadUrl("javascript:(function() { " +  
                "HybridgeGlobal = {" +
	                "isReady : true" +
	                ", version : " + HybridgeConst.VERSION +
	                ", actions : " + this.actions.toString() +
                "}" +  
                "})()");  
    } 
}
