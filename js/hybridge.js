/*!
 * tdigital-hybridge - v0.0.1
 * Bridge for mobile hybrid application between Javascript and native environment
 * (iOS & Android) in an AMD fashion.
 *
 * Copyright 2013 Telefonica Investigación y Desarrollo, S.A.U
 * Licensed AfferoGPLv3
 *
 * tdigital-hybridge is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 * tdigital-hybridge is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
 * for more details.
 * You should have received a copy of the GNU Affero General Public License along
 * with tdigital-hybridge. If not, see http://www.gnu.org/licenses/.
 *
 * For those usages not covered by the GNU Affero General Public License
 * please contact with contacto@tid.es
 */

define([
  'jquery'
], function ($) {

  var version = 1, xhr, method, logger, environment, debug, mockResponses, initialized = false,
    _events = {}, _errors;

  /**
   * Sets init configuration (native environment, logger)
   * @param {Object} ( environment: ios | android ).
   */
  function _init (conf) {
    environment = conf.environment || '';
    logger = conf.logger || null;
    debug = conf.debug || false;
    mockResponses = conf.mockResponses || null;
    /**
     * Sets up the bridge for debug mode (only browser)
     */
    if (debug) {
     _getLogger().info('Fixing bridge for debug mode');
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
      $.inArray(action, window.HybridgeGlobal.actions) !== -1 );
  }

  /**
   * Checks if the current event is implemented in native
   * @param  {String}  eventType
   * @return {Boolean}
   */
  function _isEventImplemented (event) {
    return !!(window.HybridgeGlobal && window.HybridgeGlobal.events && event && event.type &&
      $.inArray(event.type, window.HybridgeGlobal.events) !== -1 );
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
      if (mockResponses[data.action]) {
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
      else {
        warning = _errors.DEBUG_MODE;
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
        return $.Deferred()
        .then(null, fallbackFn)
        .reject({'error' : error})
        .promise();
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
   * @param  {Object} data
   * @return {Promise}
   */
  function _sendXHR (data) {
    var strJSON = JSON.stringify(data);
    if (xhr && xhr.readyState !== 4) {
        xhr = null;
    }
    var action = data.action;
    var id = data.id;
    xhr = $.ajax({
      url: 'http://hybridge/' + action + '/' + id + '/' + new Date().getTime(),
      type: 'HEAD',
      headers: { 'data': strJSON || '{}' },
      done: function() {
        if (xhr.status === 200) {
          //xhr.responseText = '{"downloaded":100}'; // Faked response (% downloaded)
          _getLogger().info('Hybridge: ' + xhr.statusText);
          xhr.resolve(JSON.parse(xhr.responseText || '{}'));
          //_handleMsgFromNative();
        }
        else {
          _getLogger().error('Hybridge: ' + xhr.statusText);
          xhr.reject({'error' : 'HTTP error: ' + xhr.status});
        }
      },
      error: function(xhr, text, textError) {
        _getLogger().error('Error on bridge to native. Non native environment?',
                           xhr, text, textError);
      }
    });
    return xhr.promise();
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
      _getLogger().warning('Hybridge: ' + _errors.DEBUG_MODE);
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
      _getLogger().warning('Hybridge: ' + _errors.DEBUG_MODE);
    }
    else {
      _getLogger().error('Hybridge: ' + _errors.EVENT_NOT_IMPLEMENTED, event);
    }
  };

  /**
   * Enables transitionend hack in to trigger callbacks directly from native
   */
  var setCSSTrigger = function (callback) {
    transitionEnd = $.support.transition ? $.support.transition.end : 'webkitTransitionEnd';
    var trigger = document.createElement('div');
    trigger.id = 'hybridgeTrigger';
    var style = document.createElement('style');
    style.id = 'triggerStyle';
    style.type = 'text/css';
    style.innerHTML = '#hybridgeTrigger{top:0;-webkit-transition:top 0.0001s;' +
      'transition:top 0.0001s;' +
      'position:absolute;visibility:hidden}' +
      '#hybridgeTrigger.switch{top:1px;}';
    document.getElementsByTagName('head')[0].appendChild(style);
    document.getElementsByTagName('body')[0].appendChild(trigger);
    $('#hybridgeTrigger').one(transitionEnd, function() {
      callback();
      $('#hybridgeTrigger').remove();
      $('#triggerStyle').remove();
    });
  };

  /**
   * Attach methods to global object in order to initialize the Hybridge properly
   * _events: Hybridge events triggered from native for client handling
   */
  var attachToGlobal = function () {
    var event;
    window.HybridgeGlobal.fireEvent = _fireEvent;
    if (window.HybridgeGlobal.events) {
      for (var i = 0; i < window.HybridgeGlobal.events.length; i++) {
        event = window.HybridgeGlobal.events[i];
        _events[event] = _createEvent(event);
      }
    }
    initialized = true;
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
   * Array containing different error types on rejecting requests (promises)
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
  _errors.EVENT_NOT_IMPLEMENTED = 'EVENT_NOT_IMPLEMENTED';
  /**
   * Hybridge in debug mode, requested feature is unavailable
   */
  _errors.DEBUG_MODE = 'DEBUG_MODE';

  /**
   * Public returned Hybridge object
   * @type {Object}
   */
  var Hybridge = {
    init: _init,
    version: version,
    isNative: _isNative,
    isEnabled: _isEnabled,
    addListener: _addListener,
    removeListener: _removeListener,
    isEventImplemented: _isEventImplemented,
    send: _send,
    events: _events,
    errors: _errors
  };

  /**
   * Since HybridgeGlobal is set from native just add the client methods
   */
  // AMD/defer load (requirejs), native bridge already loaded
  if (typeof window.HybridgeGlobal !== 'undefined') {
    attachToGlobal();
  }
  // Minified/inmediate load, native bridge loads after
  else {
    setCSSTrigger(attachToGlobal);
  }

  return Hybridge;
});
