# Hybridge

Yet another javascript / mobile native simple bridge for hybrid apps, back and forth...

## <a name='index'>Index</a>

  1. [Why?](#why)
  1. [Getting Started](#start)
   * [Dependencies](#dependencies)
      * [Javascript](#dependencies_javascript)
  1. [Usage](#usage)
   * [Javascript](#usage_javascript)
   * [Android](#usage_android)
   * [iOS](#usage_ios)
   * [Boilerplate](#usage_boilerplate)
  1. [Native Events](#events)
   * [Android](#events_android)
   * [iOS](#events_ios)
   * [Javascript](#events_javascript)
  1. [Javascript API](#api)
   * [Methods](#api_methods)
   * [Properties](#api_properties)
  1. [Debug](#debug)
  1. [Custom Errors](#errors)
  1. [Demos](#demos)
  1. [License](#license)

## <a name='why'>Why?</a>
When developing hybrid apps surely you'll need to access different native features and resources. Out there are plenty of bridge solutions.
Hybridge tries to make easy communication and data exchanging between native (iOS & Android) and Javascript worlds, avoiding too much overhead.

**[[⬆]](#index)**

## <a name='start'>Getting Started</a>
Firstly, get the code by downloading the zip or cloning the project into your local.

### <a name='dependencies'>Dependencies</a>
#### <a name='dependencies_javascript'>Javascript</a>
Hybridge works in an AMD fashion, so you'll need [RequireJS](http://requirejs.org) for the loading.
You'll also need [JQuery](http://jquery.com) (version 1.8.3 or newer) for the Javascript part since [Deferred](http://api.jquery.com/category/deferred-object) object is used intensively.

**[[⬆]](#index)**

## <a name='usage'>Usage</a>

There are two ways of communication between native and Javascript.
This is implemented in a different way in Android and iOS, but the Javascript part is just the same in both environments:
* Hybridge uses **actions** as native tasks that you want to be done when requested from Javascript while sending JSON data in the request and getting a JSON in response.

* Native Hybridge part can trigger **native events** and send attached JSON data to Javascript when needed.

### <a name='usage_javascript'>Javascript</a>
Load `hybridge.js` as a module in your AMD code. Simplest setup:
```html
  <script src="js/require.js"></script>
  <script>
  require.config({
      baseUrl: 'js/lib',
      paths: {
        jquery: 'jquery',
        hybridge: 'hybridge'
      }
  });

  requirejs(['hybridge'],
    function (Hybridge) {
      Hybridge.init({
        'environment' : 'ios'
        }
      });
    });
  </script>
```
An hypothetical `download action` defined in native could be easily invoked from Javascript:
```javascript
Hybridge.send({'action' : 'download', 'url' : 'http://...'})
```
And you'll receive a Javascript *Promise* in response to process in your callback function:
```javascript
Hybridge.send({'action' : 'gpsposition'}).done(updateMap);
```

**[[⬆]](#index)**

### <a name='usage_android'>Android</a>
* Compile the sources and copy `hybridge.jar` with your proyect libs dependencies.
Alternatively, you can set the Hybridge project as an Android library dependency.

* Create your own **actions** by implementing the interface `JsAction` as an `Enum`.
Hybridge will handle this actions inside a `Enum` listing **actions** as AsyncTask each one:
```java
public enum JsActionImpl implements JsAction {

    DOWNLOAD(DownloadTask.class),
    GPSPOSITION(GPSPositionTask.class),
    CALLCONTACT(CallContactTask.class);

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
...
}
public class DownloadTask extends AsyncTask<Object, Void, JSONObject> {

    private JsPromptResult result;
    private Context context;

    public DownloadTask(Context context) {
        this.context = context;
    }

    @Override
    protected JSONObject doInBackground(Object... params) {
        JSONObject json = (JSONObject) params[0];
        result = (JsPromptResult) params[1];
        // Process download
        ...
        return json;
    }
...
}
```

* Use `HybridgeWebChromeClient` and `HybridgeWebViewClient` in your WebView with the Enum values of your actions implementation as the constructor parameter:
```java
webView.setWebViewClient(new HybridgeWebViewClient(JsActionImpl.values()));
webView.setWebChromeClient(new HybridgeWebChromeClient(JsActionImpl.values()));
```

* Implement `Observable` in your WebView and subscribe it in order to notificate Javascript the events received from `HybridgeBroadcaster`:
```java
HybridgeBroadcaster.getInstance().addObserver(this);
...
@Override
public void update(Observable observable, Object data) {
    JSONObject json = (JSONObject) data;
    if (json.has(HybridgeConst.EVENT_NAME)) {
        try {
            HybridgeBroadcaster.getInstance().fireJavascriptEvent(mWebView, (Event) json.get(HybridgeConst.EVENT_NAME), json);
        } catch (JSONException e) {
            Log.e(mTag, "Problem with JSON object " + e.getMessage());
        }
    } else {
        HybridgeBroadcaster.getInstance().fireMessage(mWebView, json);
    }
}
```

**[[⬆]](#index)**

### <a name='usage_ios'>iOS</a>
* Compile the sources and copy the Hybridge static lib in your project `HYBHybridge.h` and `libHybridge.a`.
* Import `HYBHybridge.h` in your *UIWebView* controller.
* Bind the Hybridge singleton:

```objective-c
_hybridge = [HYBHybridge sharedInstance]
```
* Implements your native `actions` in *blocks* with the handler `HybridgeHandlerBlock_t`:

```objective-c
HybridgeHandlerBlock_t downloadHandler = ^(NSURLProtocol *url, NSString *data, NSHTTPURLResponse *response) {
    NSDictionary *params = [_parser objectWithString:data];
    // Handle download with data from Javascript request
    ...
};
```
* You'll parse the JSON `data` sent from Javascript as seen in the previous code snippet.
* Finally, subscribe each of your `actions` to the Hybridge by binding to the name you'll use to invoke it from Javascript.

```objective-c
[_hybridge subscribeAction:@"download" withHandler:downloadHandler];
```

**[[⬆]](#index)**

### <a name='usage_boilerplate'>Boilerplate</a>
The fastest track to start using Hybridge is use the Boilerplate.

Firstly, You'll need a local server running in you development environment to load initially the test files.
There are both supported environment projects for iOS and Android and on the other hand a test HTML file called `hybridge.html` that you can put in the root of your local server,
along with the `hybridge.js` file as a development start of your app.
All you need is to place those files in your local web documents root and modify them as your convenience, as well as change the original local test path (`http://127.0.0.1/hybridge.html`) to another URL.
In this way is really simple to migrate from a previous web application to a hybrid one.
Nevertheless, a HTTP path is needed since currently Hybridge doesn't support load of local HTML files.

**[[⬆]](#index)**

## <a name='events'>Native Events</a>
You can communicate to Javascript from Android/iOS by triggering any of the defined `events` in Hybridge for recommended use:
* **ready**: Hybridge initialization.
* **pause**: Mobile app goes background.
* **resume**: Mobile app goes foreground.
* **message**: Send arbitrary data when required.

### <a name='events_android'>Android</a>
Use *HybridgeBroadcaster* singleton to trigger events in Javascript:
```java
HybridgeBroadcaster.getInstance().fireJavascriptEvent(webView, Event.READY, jsonData);
```

### <a name='events_ios'>iOS</a>
Use *Hybridge* singleton to trigger events in Javascript:
```objective-c
[_hybridge fireEventInWebView:kHybridgeEventReady data:@"{foo : \"data\"}" web:self.webview]
```

### <a name='events_javascript'>Javascript</a>
Subscribe your Javascript on `ready` event to the native events in order to process the data received in a callback function:
```javascript
function processData (event) {
  var data = ev.data;
  ...
}

Hybridge.addListener(Hybridge.events.ready, function () {
  Hybridge.addListener(Hybridge.events.message, processData);
  ...
});
```
Don't forget to remove your handlers to avoid memory leaks:
```javascript
Hybridge.removeListener(Hybridge.events.message, processData);
```
**[[⬆]](#index)**

## <a name='api'>Javascript API</a>
A good enough start could be simply look over the code from [**hybridge.js**](js/hybridge.js), nevertheless,
let's enumerate the available methods and properties from the Hybridge Javascript object:

### <a name='api_methods'>Methods</a>
* **init(configuration:Object)**
 Provides initialization configuration:
 * *environment* (ios|android : *String*): mandatory, as long as you want to communicate with native side.
 * *logger* (Function): optional logger object handler, otherwise `window.console` object is used for standard output.
 * *debug* (boolean): activates debug (web side) mode, more information on this next.
 * *mockResponses* (Object): provides optional mock object for debug mode.

* **isNative()**
 Returns true if *environment* value is correctly assigned.
* **isEnabled()**
 Returns true if Hybridge is already initialized (native and Javascript parts) or `debug` mode is on.
* **addListener(hybridgeEvent:Event, callback:Function)**
 Subscribes a `Hybridge event` to a callback handler.
* **removeListener(hybridgeEvent:Event, callback:Function)**
 Unsubscribes a `Hybridge event` to a callback handler.
* **isEventImplemented(hybridgeEvent:String)**
 Returns true if the event is implemented in the current native version of Hybridge.
* **isActionImplemented(hybridgeEvent:String)**
 Returns true if the action is implemented in the current native version of Hybridge.
* **send(data:Object[, fallback:Function])**
 Provides the way to communicate from Javascript to native side. An `action` parameter is required in order to execute an implemented native task.
 Returns a [JQuery](http://jquery.com) [Promise](http://api.jquery.com/Types/#Promise) containing data returned from native or custom error.
 You can add a second function parameter `fallback` in case something goes wrong and you want to supply aditional user feedback as well as update your UI.

### <a name='api_properties'>Properties</a>
* **errors** Container object of customs errors returned by the Hybridge:
 * *NO_NATIVE*: Environment is not mobile native (ios or android).
 * *NO_NATIVE_ENABLE*: Native environment doesn't support native Hybridge.
 * *NO_FALLBACK*: Call to hybridge lacks of fallback function.
 * *ACTION_NOT_IMPLEMENTED*: Call to hybridge action not implemented in native.
 * *WRONG_PARAMS*: Call to hybridge doesn't have required parameters (action).
 * *EVENT_NOT_IMPLEMENTED*: Call to hybridge event not implemented in native.
 * *DEBUG_MODE*: Hybridge in debug mode, requested feature is unavailable.
 * *MALFORMED_JSON*: Hybridge attempted to parse or stringify malformed JSON (debug mode).
* **events** Container object of available [native events](#native-events).
* **version** Current version of Javascript Hybridge.

**[[⬆]](#index)**

## <a name='debug'>Debug</a>
Hybridge provides a easy way to mock native mobile responses as you work on the UI development parts. Given a `downloadStatus` action it can be mocked on Hybridge initialization:
```javascript
Hybridge.init({
  'environment': 'android',
  'logger': CustomLoger,
  'debug': true,
  'mockResponses': {
    'downloadStatus': {
      'downloadedPercentage': 50
    }
  }
});
```
When the page calls `downloadStatus` action, a prompt window will show the JSON mock data. It can be modified as you please for your UI tests.

**[[⬆]](#index)**

## <a name='errors'>Custom Errors</a>
In a typical scenario, where web and installed native parts can be different versions you can deal with it by handling the custom error returned:
```javascript
Hybridge.send({
    'action' : 'download',
    'url' : url
  })
  .done(updateUIfunction)
  .fail(function (e) {
    if (e.error && e.error === Hybridge.errors.ACTION_NOT_IMPLEMENTED) {
      // Advise user to update native applicacion to the newest version
      ...
    }
  });
```

**[[⬆]](#index)**

## <a name='demos'>Demos</a>
Coming soon...

**[[⬆]](#index)**

## <a name='license'>License</a>
Copyright (c) 2013 Telefonica Digital
Licensed under the AfferoGPLv3 license.
