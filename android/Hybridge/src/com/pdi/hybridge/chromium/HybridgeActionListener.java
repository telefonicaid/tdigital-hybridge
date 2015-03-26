
package com.pdi.hybridge.chromium;

import org.json.JSONObject;

public interface HybridgeActionListener {

    public void onInitHybridge(JSONObject data);

    public void onLoadError(int errorCode, String description, String failingUrl);
}
