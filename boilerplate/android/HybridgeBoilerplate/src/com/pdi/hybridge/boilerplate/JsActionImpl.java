/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: MIT (see LICENSE file)
 */

package com.pdi.hybridge.boilerplate;

import com.pdi.hybridge.JsAction;
import com.pdi.hybridge.boilerplate.action.GetBatteryTask;
import com.pdi.hybridge.boilerplate.action.GetTimeTask;

@SuppressWarnings("rawtypes")
public enum JsActionImpl implements JsAction {

    TIME(GetTimeTask.class), BATTERY(GetBatteryTask.class);

    private Class task;

    private JsActionImpl(Class task) {
        this.setTask(task);
    }

    @Override
    public Class getTask() {
        return task;
    }

    @Override
    public void setTask(Class task) {
        this.task = task;
    }

}
