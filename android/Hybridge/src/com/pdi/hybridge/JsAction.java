package com.pdi.hybridge;

import android.content.Context;


@SuppressWarnings("rawtypes")
public interface JsAction {
	
	public void setContext(Context context);
	
    public Class getTask();

	public void setTask(Class task);

}
