# Hybridge

Yet another javascript / mobile native simple bridge for hybrid apps, back and forth...

## Why?
When developing hybrid apps surely you'll need to access different native features and resources. Out there are plenty of bridge solutions.
Hybridge tries to make easy communication and data exchanging between native (iOS & Android) and Javascript worlds, avoiding too much overhead.

---
## Getting Started
Firstly, get the code by downloading the zip or cloning the project into your local.

### Dependencies
#### Javascript
Hybridge works in an AMD fashion, so you'll need [RequireJS](http://requirejs.org) for the loading.
You'll also need [JQuery](http://jquery.com) (version 1.5 or newer) for the Javascript part since [Deferred](http://api.jquery.com/category/deferred-object) object is used intensively.

#### iOS
 The only Objective-C dependency is [SBJson](http://superloopy.io/json-framework) and is handled for the grace of [CocoaPods](http://cocoapods.org) which is ridiculously easy to setup. 

#### Android

None.

---
## Usage

There are two ways of communication between native and Javascript.
This is implemented in a different way in Android and iOS, but the Javascript part is just the same in both environments:
* Hybridge uses **actions** as native tasks that you want to be done when requested from Javascript while sending JSON data in the request and getting a JSON in response. 

* Native Hybridge part can trigger **custom events** and send attached JSON data to Javascript when needed.

### Javascript
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
Hybridge.send({'action': 'download', 'url': 'http://...'})
```

###Android
* Compile the sources and copy `hybridge.jar` with your proyect libs dependencies. Alternatively, you can set the Hybridge project as a Android library dependency.

* Create your own **actions** by implementing the interface `JsAction` as an `Enum`. 
Hybridge will handle this actions inside a `Enum` listing **actions** as AsyncTask each one:
```java
public enum JsActionImpl implements JsAction {

    DOWNLOAD(DownloadTask.class),
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
    
    public class DownloadTask extends AsyncTask<Object, Void, JSONObject> {

        private JsPromptResult result;
        private Context context;

        public LoginTask(Context context) {
            this.context = context;
        }

        @Override
        protected JSONObject doInBackground(Object... params) {
            JSONObject json = (JSONObject) params[0];
            result = (JsPromptResult) params[1];
            // Process download
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

###iOS
Coming soon...


