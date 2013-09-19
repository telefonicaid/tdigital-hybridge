package com.pdi.hybridgedemo;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.webkit.ConsoleMessage;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.pdi.hybridge.HybridgeWebChromeClient;
import com.pdi.hybridge.HybridgeWebViewClient;

public class MainActivity extends Activity {

	protected String mTag = "MainActivity";
	private WebView mWebView;
	
	@SuppressLint("SetJavaScriptEnabled")
	@Override
	protected void onResume() {
		super.onResume();
	}
	
	@SuppressLint("SetJavaScriptEnabled")
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_fullscreen);
		
		mWebView = (WebView) findViewById(R.id.webview);
		
		mWebView.setBackgroundColor(0);
		mWebView.getSettings().setJavaScriptEnabled(true);
		mWebView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
        mWebView.clearCache(true);
        mWebView.clearFormData();
        mWebView.setWebViewClient(webViewClient);
        mWebView.setWebChromeClient(webChromeClient);
		mWebView.loadUrl("http://play.tid.es/M5/feature/10981/dev4/");
		// Jenkins:
		// http://ci-enjoymobile/release/feature/10981/dev4/
		// http://play.tid.es/M5/feature/10981/dev4/ 
		// Direct D2P movie example:
		// http://192.168.1.34/#movies/18/tintin
		// Local:
		// file:///android_asset/www/index.html
		// Cert:
		// http://ci-enjoymobile/release/feature/10981/homolog-cert/
	}
	
    /**
     * Private webChromeClient implementation
     */
    private final HybridgeWebChromeClient webChromeClient = new HybridgeWebChromeClient(JsActionImpl.values()) {
        @Override
        public boolean onConsoleMessage(ConsoleMessage cm) {
        	android.util.Log.v(mTag, cm.message());
            return true;
        }  
    };
    
    private final HybridgeWebViewClient webViewClient = new HybridgeWebViewClient(JsActionImpl.values()) {

    };

}
