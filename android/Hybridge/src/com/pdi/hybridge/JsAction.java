/**
 * Hybridge
 * (c) Telefonica Digital, 2015 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge;

@SuppressWarnings("rawtypes")
public interface JsAction {

    public Class getTask();

    public void setTask(Class task);

}
