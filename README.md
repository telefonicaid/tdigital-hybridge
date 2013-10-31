# Hybridge

Yet another javascript / mobile native simple bridge for hybrid apps, back and forth...

## Why?
When developing hybrid apps surely you'll need to access different native features and resources. Out there are plenty of bridge solutions.
Hybridge tries to make easy communication between native (iOS & Android) and javascript worlds, avoiding too much overhead.

## Dependencies
### Javascript
Hybridge works in an AMD fashion, so you'll need [RequireJS](http://requirejs.org) for the loading.
You'll also need [JQuery](http://jquery.com) (> 1.5) for the Javascript part since [Deferred](http://api.jquery.com/category/deferred-object) object is used intensively.

### iOS
 The only Objective-C dependency is [SBJson](http://superloopy.io/json-framework) and is handled for the grace of [CocoaPods](http://cocoapods.org) which is ridiculously easy to setup. 

### Android

None.
