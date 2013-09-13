package com.pdi.hybridge;

import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class HybridgeWebViewClient extends WebViewClient {
    @Override
    public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
        return super.shouldInterceptRequest(view, url);
    }
    
    @Override  
    public void onPageFinished(WebView view, String url) {  
        view.loadUrl("javascript:(function() { " +  
                "HybridgeGlobal={isReady:true,version:1}" +  
                "})()");  
    } 
}
