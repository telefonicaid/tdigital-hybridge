/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge;

@SuppressWarnings("rawtypes")
public interface JsAction {

    public Class getTask();

    public void setTask(Class task);

}
