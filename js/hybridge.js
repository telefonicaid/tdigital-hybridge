/*!
 * tdigital-hybridge - v1.4.0
 * Bridge for mobile hybrid application between Javascript and native environment
 * (iOS & Android)
 *
 * Copyright 2015 Telefonica Investigación y Desarrollo, S.A.U
 * Licensed under MIT License.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the “Software”), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    define(['jquery'], factory);
  } else {
    // Browser globals
    root.Hybridge = factory(root.jQuery);
  }
}(this, function ($) {
  'use strict';

  var READY_EVENT = 'ready';
  var INIT_ACTION = 'init';
  var CUSTOM_DATA_OBJ = 'customData';

  var version = 1, versionMinor = 4, initialized = false,
    xhr, method, logger, environment, debug, mockResponses, _events = {}, _actions = [], _errors,
    initModuleDef = $.Deferred(), initGlobalDef = $.Deferred(), initCustomDataDef = $.Deferred();

  /**
   * Sets init configuration (native environment, logger)
   * @param {Object} ( environment: ios | android, customData ).
   * @param {Function} customDataCb
   */
  function _init (conf, customDataCb) {
    environment = conf.environment || '';
    logger = conf.logger || null;
    debug = conf.debug || false;
    mockResponses = conf.mockResponses || null;
    /**
     * Sets up the bridge for debug mode (only browser)
     */
    if (debug) {
     _getLogger().info('Fixing bridge for debug mode');
     _mockHybridgeGlobal(conf);
    }
    /**
     * Sets up the bridge in iOS environment
     */
    else if (_isIos()) {
      _getLogger().info('Fixing bridge for iOS, XHR method used');
      method = _sendXHR;
    }
    /**
    * Sets up the bridge in Android environment
    */
    else if (_isAndroid()) {
      _getLogger().info('Fixing bridge for Android, prompt method used');
      method = _sendPrompt;
    }
    $.when(initCustomDataDef).then(customDataCb);

    return initModuleDef.resolve(conf).promise();
  }

  /**
   * Notify native of javascript initialization
   * @return {Object} Promise returned from send method
   */
  function _initNative (deferredModule, deferredGlobal) {
    _send({
      'action' : INIT_ACTION,
      'initialized' : deferredGlobal.initialized,
      'version' : version,
      'versionMinor' : versionMinor,
      'timestamp' : Date.now()
    });
  }

  /**
   * Returns the logger object
   * @return {Object}
   */
  function _getLogger () {
    if (!logger) {
      logger = window.console;
    }
    return logger;
  }

  /**
   * Checks if the current native environment is native
   * @return {Boolean}
   */
  function _isNative () {
    return (_isIos() || _isAndroid());
  }

  /**
   * Checks if the current native environment is iOS
   * @return {Boolean}
   */
  function _isIos () {
    return environment === 'ios';
  }

  /**
   * Checks if the current native environment is Android
   * @return {Boolean}
   */
  function _isAndroid () {
    return environment === 'android';
  }

  /**
   * Checks if the bridge has been started from native
   * @return {Boolean}
   */
  function _isEnabled () {
    return !!(debug || (window.HybridgeGlobal && window.HybridgeGlobal.isReady && initialized));
  }

  /**
   * Checks if the current action is implemented in native
   * @param  {String}  action
   * @return {Boolean}
   */
  function _isActionImplemented (action) {
    return !!(window.HybridgeGlobal && window.HybridgeGlobal.actions &&
      (action == INIT_ACTION || $.inArray(action, window.HybridgeGlobal.actions) !== -1));
  }

  /**
   * Checks if the current event is implemented in native
   * @param  {String}  eventType
   * @return {Boolean}
   */
  function _isEventImplemented (event) {
    return !!((event && event.type === READY_EVENT) ||
      (window.HybridgeGlobal && window.HybridgeGlobal.events && event && event.type &&
      $.inArray(event.type, window.HybridgeGlobal.events) !== -1));
  }

  /**
   * Checks the current environment and forwards to the proper bridge method
   * @param  {Object} data
   * @param  {Function} fallbackFn
   * @return {Promise}
   */
  function _send (data, fallbackFn) {
    var error, warning, details, mock;
    // Is mode debug on
    if (debug) {
      // Fire the ready event as a response for the init action
      if (data.action == INIT_ACTION) {
        _fireEvent(READY_EVENT, {});
      } else if (mockResponses && mockResponses[data.action]) {
        mock = $.extend({}, data, mockResponses[data.action]);
        try {
          return $.Deferred().resolve(
            JSON.parse(window.prompt('Hybridge Debug - JSON response:', JSON.stringify(mock)))
          ).promise();
        }
        catch (e) {
          error = _errors.MALFORMED_JSON;
          details = e.message;
        }
      }
      else {
        warning = _errors.DEBUG_MODE;
        details = data.action;
      }
    }
    // Is a native environment
    else if(_isNative()) {
      // Native bridge is enabled
      if (_isEnabled()) {
        if (data.action) {
          if (_isActionImplemented(data.action)) {
            return method(data);
          }
          else {
            error = _errors.ACTION_NOT_IMPLEMENTED;
            details = data.action;
          }
        }
        else {
          error = _errors.WRONG_PARAMS;
          details = JSON.stringify(data);
        }
      }
      // Native bridge is disabled, try fallback function
      else if (fallbackFn) {
        error = _errors.NO_NATIVE_ENABLED;
        var def = $.Deferred();
        def.then(null, fallbackFn);
        def.reject({'error' : error});
        return def.promise();
      }
      else {
        error = _errors.NO_FALLBACK;
      }
    }
    else {
      error =  _errors.NO_NATIVE;
    }
    return $.Deferred().reject({'error' : error, 'warning' : warning, 'details' : details}).promise();
  }

  /**
   * Provides prompt method override bridge method for Android environment
   * @param  {Object} data
   * @return {Promise}
   */
  function _sendPrompt (data) {
    var def = $.Deferred();
    var strJSON = JSON.stringify(data);
    var action = data.action;
    var result = null;
    setTimeout(function() {
      try {
        result = JSON.parse(window.prompt(action, strJSON) || '{}');
        def.resolve(result);
      }
      catch (e) {
        _getLogger().error('Hybridge: Error on prompt processing');
        def.reject({'error' : e.message});
      }
    });
    return def.promise();
  }

  /**
   * Provides XHR bridge method for iOS environment
   * Warning: Fixed to work with JQuery 1.10.2
   * @param  {Object} data
   * @return {Promise}
   */
  function _sendXHR (data) {
    var strJSON = JSON.stringify(data);
    if (xhr && xhr.readyState !== 4) {
        xhr = null;
    }
    var def = $.Deferred();
    var action = data.action;
    var id = data.id;
    xhr = $.ajax({
      url: 'http://hybridge/' + action + '/' + id + '/' + new Date().getTime(),
      type: 'HEAD',
      headers: { 'data': strJSON || '{}' }
    });
    xhr.done(function() {
        if (xhr.status === 200) {
          _getLogger().info('Hybridge: ' + xhr.statusText);
          def.resolve(JSON.parse(xhr.responseText || '{}'));
        }
        else {
          _getLogger().error('Hybridge: ' + xhr.statusText);
          def.reject({'error' : 'HTTP error: ' + xhr.status});
        }
      });
    xhr.fail(function(xhr, text, textError) {
        _getLogger().error('Error on bridge to native. Non native environment?',
                           xhr, text, textError);
      });
    return def.promise();
  }

  /**
   * Method required for backwards compatibility
   * with DOM Level 2 event creation (Android Webkit)
   * @param  {String} name
   * @return {Event}
   */
  var _createEvent = function (name) {
    var ev = null, CE = window.CustomEvent;
    // DOM Level 3
    if (typeof CE !== 'undefined') {
      ev = new CE(name);
    }
    // DOM Level 2
    else {
      ev = document.createEvent('Event');
      ev.initEvent(name, true, true);
    }
    return ev;
  };

  /**
   * Add a handler to a Hybridge event if present
   * @param {Event} event
   * @param {Function} callback
   */
  var _addListener = function (event, callback) {
    if (_isEventImplemented(event)) {
      document.addEventListener(event.type, callback, false);
    }
    else if (debug) {
      _getLogger().log('Hybridge: ' + _errors.DEBUG_MODE);
    }
    else {
      _getLogger().error('Hybridge: ' + _errors.EVENT_NOT_IMPLEMENTED, event);
    }
  };

  /**
   * Removes a handler from a Hybridge event
   * @param {Event} event
   * @param {Function} callback
   */
  var _removeListener = function (event, callback) {
    if (_isEventImplemented(event)) {
      document.removeEventListener(event.type, callback, false);
    }
    else if (debug) {
      _getLogger().log('Hybridge: ' + _errors.DEBUG_MODE);
    }
    else {
      _getLogger().error('Hybridge: ' + _errors.EVENT_NOT_IMPLEMENTED, event);
    }
  };

  /**
   * Creates a mock for the HybridgeGlobal object, as created by the native app.
   */
  var _mockHybridgeGlobal = function (conf) {
    window.HybridgeGlobal || setTimeout(function() {
        window.HybridgeGlobal = {
          isReady: true,
          version: version,
          versionMinor: versionMinor,
          actions: [INIT_ACTION, 'message'],
          events: [READY_EVENT, 'message'],
          customData: conf.customData || {}
        };
      }, 0);
  };

  /**
   * Attach methods to global object in order to initialize the Hybridge properly
   * _events: Hybridge events triggered from native for client handling
   */
  var _attachToGlobal = function () {
    var event, globalEvents, globalActions;
    if (window.HybridgeGlobal && (globalEvents = window.HybridgeGlobal.events)) {
      for (var i = 0; i < globalEvents.length; i++) {
        event = globalEvents[i];
        if (!_events[event]) {
          _events[event] = _createEvent(event);
        }
      }
    }
    if (window.HybridgeGlobal && (globalActions = window.HybridgeGlobal.actions)) {
      for (var i in globalActions) {
        if (globalActions.hasOwnProperty(i)) {
         _actions.push(globalActions[i]);
        }
      }
    }
    if (window.HybridgeGlobal && (globalActions = window.HybridgeGlobal.customData)) {
      Hybridge[CUSTOM_DATA_OBJ] = $.extend({}, window.HybridgeGlobal.customData);
      initCustomDataDef.resolve(Hybridge[CUSTOM_DATA_OBJ]).promise();
    }

    initialized = true;
    window.HybridgeGlobal.fireEvent = _fireEvent;
    window.HybridgeGlobal.initialized = initialized;
    return initGlobalDef.resolve({'initialized':initialized}).promise();
  };

  /**
   * Global method used from native to trigger events (scope HybridgeGlobal)
   */
  var _fireEvent = function (type, data) {
    if (_events[type]) {
      _events[type].data = data;
      return document.dispatchEvent(_events[type]);
    }
    else {
      _getLogger().error('Hybridge event not defined: ' + type);
    }
  };

  /**
   * Function to notify whenever Hybridge becomes or is enabled/ready
   *
   * If hybridge is ready at calling time, the callback is inmediatelly executed
   *
   * @param {Function} cb  Callback to be called once Hybridge is ready
   */
  function _ready(cb) {
    if (_isEnabled()) {
      cb();
    } else {
      _addListener(_events.ready, function onReady() {
        _removeListener(_events.ready, onReady);
        cb();
      });
    }
  }

  /**
   * Object containing different error types on rejecting requests (promises)
   * @type {Array}
   */
  _errors = {};
  /**
   * Environment is not mobile native (ios or android)
   */
  _errors.NO_NATIVE = 'NO_NATIVE';
  /**
   * Native environment doesn't support native Hybridge
   */
  _errors.NO_NATIVE_ENABLE = 'NO_NATIVE_ENABLED';
  /**
   * Call to hybridge lacks of fallback function
   */
  _errors.NO_FALLBACK = 'NO_FALLBACK';
  /**
   * Call to hybridge action not implemented in native
   */
  _errors.ACTION_NOT_IMPLEMENTED = 'ACTION_NOT_IMPLEMENTED';
  /**
   * Call to hybridge doesn't have required parameters (action)
   */
  _errors.WRONG_PARAMS = 'WRONG_PARAMS';
  /**
   * Call to hybridge event not implemented in native
   */
  _errors.EVENT_NOT_IMPLEMENTED = 'EVENT_NOT_IMPLEMENTED';
  /**
   * Hybridge in debug mode, requested feature is unavailable
   */
  _errors.DEBUG_MODE = 'DEBUG_MODE';
  /**
   * Hybridge attempted to parse or stringify malformed JSON (debug mode)
   */
  _errors.MALFORMED_JSON = 'MALFORMED_JSON';

  /**
   * Public returned Hybridge object
   * @type {Object}
   */
  var Hybridge = {
    init: _init,
    version: version,
    versionMinor: versionMinor,
    isNative: _isNative,
    isEnabled: _isEnabled,
    addListener: _addListener,
    removeListener: _removeListener,
    isEventImplemented: _isEventImplemented,
    isActionImplemented: _isActionImplemented,
    send: _send,
    events: _events,
    actions: _actions,
    errors: _errors,
    ready: _ready
  };

  /**
   * Inits ready event
   */
  _events.ready = _createEvent(READY_EVENT);

  /**
   * window.HybridgeGlobal is set by the Native code in other thread outside
   * the browser event loop.
   * Lets going to poll for it and then we can be sure native has done
   * its part in the handshake
   *
   * TODO: Refactor the handshake protocol, forcing native to start once the
   * webview is DOMReady and a document the minimun initial DOM for using
   * the old CSS trigger from version 1.2.0
   */
  (function _checkForGlobal() {
    if (!!window.HybridgeGlobal) {
      _attachToGlobal();
    } else {
      setTimeout(_checkForGlobal, 10);
    }
  })();

  /**
   * Initialize both native and javascript
   */
  $.when(initModuleDef, initGlobalDef).then(_initNative);

  return Hybridge;
}));