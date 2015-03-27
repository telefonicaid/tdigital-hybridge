/**
 * Hybridge
 * (c) Telefonica Digital, 2015 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.chromium;

import org.json.JSONObject;

public interface HybridgeActionListener {

    public void onInitHybridge(JSONObject data);

    public void onLoadError(int errorCode, String description, String failingUrl);
}
