/**
 * Hybridge
 * (c) Telefonica Digital, 2015 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge;

public class HybridgeConst {

    public static final int VERSION = 1;
    public static final int VERSION_MINOR = 4;

    public static final String EVENT_NAME = "event";
    public static final String ACTION_INIT = "init";

    public enum Event {
        PAUSE("pause"), RESUME("resume"), MESSAGE("message"), READY("ready");

        private String jsName;

        private Event(String jsName) {
            this.jsName = jsName;
        }

        public String getJsName() {
            return this.jsName;
        }
    }
}
