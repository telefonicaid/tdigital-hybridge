
package com.pdi.hybridge;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.util.AttributeSet;
import android.util.Log;

import com.pdi.hybridge.HybridgeConst.Event;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.xwalk.core.XWalkJavascriptResult;
import org.xwalk.core.XWalkPreferences;
import org.xwalk.core.XWalkResourceClient;
import org.xwalk.core.XWalkUIClient;
import org.xwalk.core.XWalkView;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;

@SuppressLint("SetJavaScriptEnabled")
public class HybridgeXWalkView extends XWalkView {

    private static final String TAG = HybridgeXWalkView.class.getSimpleName();

    @SuppressWarnings("rawtypes")
    protected HashMap<String, Class> mActions;

    protected JSONObject mCustomData;

    private HybridgeActionListener mHybridgeActionListener;

    @SuppressWarnings("unused")
    private Context mContext;

    private String mTitle;

    /**
     * Constructor.
     * 
     * @param context
     */
    public HybridgeXWalkView(Context context, Activity activity) {
        super(context, activity);
        init(context);
    }

    /**
     * Constructor.
     * 
     * @param context
     * @param attrs
     */
    public HybridgeXWalkView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    /**
     * Constructor.
     * 
     * @param context
     * @param attrs
     * @param defStyle
     */
    public HybridgeXWalkView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs);
        init(context);
    }

    /**
     * Sets the javascript actions available from web.
     * 
     * @param actions
     */
    @SuppressLint("DefaultLocale")
    @SuppressWarnings("rawtypes")
    public void setJsActions(JsAction[] actions) {
        mActions = new HashMap<String, Class>(actions.length);
        for (final JsAction action : actions) {
            mActions.put(action.toString().toLowerCase(), action.getTask());
        }
    }

    /**
     * @return the mHybridgeActionListener
     */
    public HybridgeActionListener getHybridgeActionListener() {
        return mHybridgeActionListener;
    }

    /**
     * @param mHybridgeActionListener the mHybridgeActionListener to set
     */
    public void setHybridgeActionListener(HybridgeActionListener hybridgeActionListener) {
        try {
            mHybridgeActionListener = hybridgeActionListener;
        } catch (final ClassCastException e) {
            throw new ClassCastException(hybridgeActionListener.toString()
                    + " must implement HybridgeActionListener");
        }
    }

    public void setCustomData(JSONObject customData) {
        mCustomData = customData;
    }

    public void setTitle(String title) {
        mTitle = title;
    }

    @Override
    public String getTitle() {
        return mTitle;
    }

    @Override
    public void onDestroy() {
        mActions = null;
        mContext = null;
        mHybridgeActionListener = null;
        super.onDestroy();
    }

    private void init(Context context) {
        setResourceClient(new ResourceClient(this));
        setUIClient(new UIClient(this));
    }

    public void fireJavascriptEvent(final XWalkView view, final Event event, final JSONObject data) {

        final String json = data != null ? data.toString() : "{}";
        final StringBuffer js = new StringBuffer("HybridgeGlobal.fireEvent(\"");
        js.append(event.getJsName()).append("\",").append(json).append(");");
        evaluateJavascript(js.toString(), null);
    }

    protected class ResourceClient extends XWalkResourceClient {

        public ResourceClient(XWalkView view) {
            super(view);
        }

        @Override
        public void onReceivedLoadError(XWalkView view, int errorCode, String description,
                String failingUrl) {
            super.onReceivedLoadError(view, errorCode, description, failingUrl);
            mHybridgeActionListener.onLoadError(errorCode, description, failingUrl);
        }
    }

    protected class UIClient extends XWalkUIClient {

        public UIClient(XWalkView view) {
            super(view);
        }

        @Override
        public boolean onJavascriptModalDialog(XWalkView view, JavascriptMessageType type,
                String url, String action, String data, XWalkJavascriptResult result) {

            if (type.equals(JavascriptMessageType.JAVASCRIPT_PROMPT)) {
                try {
                    final JSONObject json = new JSONObject(data);
                    if (action.equals(HybridgeConst.ACTION_INIT)) {
                        result.confirmWithResult(data);
                        json.put(HybridgeConst.EVENT_NAME, HybridgeConst.Event.READY);
                        mHybridgeActionListener.onInitHybridge(json);
                        fireJavascriptEvent(view, Event.READY, json);
                    } else {
                        executeTask(action, json, result);
                    }
                } catch (final JSONException e) {
                    result.confirmWithResult(data);
                    e.printStackTrace();
                }
                return true;
            } else {
                return super.onJavascriptModalDialog(view, type, url, action, data, result);
            }
        }

        @SuppressWarnings({
            "rawtypes", "unchecked"
        })
        private void executeTask(String action, JSONObject json, XWalkJavascriptResult result) {
            final Class clazz = mActions.get(action);
            final Activity activity = (Activity) getContext();
            if (clazz != null && activity != null) {
                AsyncTask task = null;
                try {
                    task =
                            (AsyncTask<JSONObject, Void, JSONObject>) clazz.getDeclaredConstructor(
                                    new Class[] {
                                        android.app.Activity.class
                                    }).newInstance(activity);
                } catch (final InstantiationException e) {
                    e.printStackTrace();
                } catch (final IllegalAccessException e) {
                    e.printStackTrace();
                } catch (final IllegalArgumentException e) {
                    e.printStackTrace();
                } catch (final InvocationTargetException e) {
                    e.printStackTrace();
                } catch (final NoSuchMethodException e) {
                    e.printStackTrace();
                }
                task.execute(json, result, mHybridgeActionListener);
            } else {
                result.confirmWithResult(json.toString());
                Log.d(TAG, "Hybridge action not implemented: " + action);
            }
        }

        /**
         * Inits the Hybridge global object in javascript and sets the page title is has been
         * previously settled.
         */
        @SuppressLint("DefaultLocale")
        @Override
        public void onPageLoadStopped(XWalkView view, String url, LoadStatus status) {
            super.onPageLoadStopped(view, url, status);
            if (status == LoadStatus.FINISHED) {
                JSONArray actions = new JSONArray();
                if (mActions != null) {
                    actions = new JSONArray(mActions.keySet());
                }
                final JSONArray events = new JSONArray();
                final Event[] eventsList = HybridgeConst.Event.values();
                for (final Event event : eventsList) {
                    events.put(event.getJsName());
                }
                final String jsString =
                        "window.HybridgeGlobal || (function () {"
                                + "window.HybridgeGlobal = {" + "  isReady : true" + ", version : "
                                + HybridgeConst.VERSION + ", versionMinor : "
                                + HybridgeConst.VERSION_MINOR + ", actions : " + actions.toString()
                                + ", events : " + events.toString() + ", customData : "
                                + (mCustomData != null ? mCustomData.toString() : "{}") + "};"
                                + (mTitle != null ? ("document.title='" + mTitle + "';") : "")
                                + "})();";
                view.evaluateJavascript(jsString, null);
            }
        }
    }

    static {
        // XWalkPreferencesInternal.ENABLE_JAVASCRIPT
        XWalkPreferences.setValue("enable-javascript", true);
    }
}
