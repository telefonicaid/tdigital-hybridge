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
  'jquery',
  'init-has',
  'tid'
], function ($, has, TID) {

  var xhr = null;
  var method = null;
  var logger = TID.Logger.getLogger(TID.Logger.Facility.DEFAULT, 'Hybridge');

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
    return has('ios_native');
  }

  /**
   * Checks if the current native environment is Android
   * @return {Boolean}
   */
  function _isAndroid () {
    return has('android');
  }

  /**
   * Checks if the bridge has been started from native
   * @return {Boolean}
   */
  function _isEnabled () {
    return !!(window.HybridgeGlobal && HybridgeGlobal.isReady);
  }

  /**
   * Checks if the current action is implemented in native
   * @param  {String}  action
   * @return {Boolean}
   */
  function _isActionImplemented (action) {
    return !!(window.HybridgeGlobal && HybridgeGlobal.actions && $.inArray(action, HybridgeGlobal.actions)!=-1 );
  }

  /**
   * Checks the current environment and forwards to the proper bridge method
   * @param  {Object} data
   * @param  {Function} fallbackFn
   * @return {Promise}
   */
  function _send (data, fallbackFn) {
    var error;
    // Is a native environment
    if(_isNative()) {
      // Native bridge is enabled
      if (_isEnabled()) {
        if (data.action) {
          if (_isActionImplemented(data.action)) {
            return method(data);
          }
          else {
            error = _errors.ACTION_NOT_IMPLEMENTED;
          }
        }
        else {
          error = _errors.WRONG_PARAMS;
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
    return $.Deferred().reject({'error' : error}).promise();
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
        result = JSON.parse(prompt(action, strJSON) || '{}');
        def.resolve(result);
      }
      catch (e) {
        logger.error('Hybridge: Error on prompt processing');
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
    if (xhr && xhr.readyState != 4) {
        xhr = null;
    }
    var action = data.action;
    var id = data.id;
    xhr = $.ajax({
      url: 'http://hybridge/' + action +'/' + id + '/' + new Date().getTime(),
      type: 'HEAD',
      headers: { 'data': strJSON || '{}' },
      done: function() {
        if(xhr.status === 200) {
          //xhr.responseText = '{"downloaded":100}'; // Faked response (% downloaded)
          logger.info('Hybridge: ' + xhr.statusText);
          xhr.resolve(JSON.parse(xhr.responseText || '{}'));
          //_handleMsgFromNative();
        }
        else {
          logger.error('Hybridge: ' + xhr.statusText);
          xhr.reject({'error' : 'HTTP error: ' + xhr.status});
        }
      },
      error: function(xhr, text, textError) {
        logger.error('Error on bridge to native. Non native environment?');
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
    var ev = null;
    // DOM Level 3
    if(typeof CustomEvent != 'undefined') {
      ev = new CustomEvent(name);
    }
    // DOM Level 2
    else {
      ev = document.createEvent('Event');
      ev.initEvent(name, true, true);
    }
    return ev;
  };

  /**
   * Hybridge events triggered from native for client handling
   * @type {Array}
   */
  var _events = [];
  _events.HybridgeReady = _createEvent('HybridgeReady');
  _events.HybridgeMessage = _createEvent('HybridgeMessage');
  _events.HybridgePause = _createEvent('HybridgePause');
  _events.HybridgeResume = _createEvent('HybridgeResume');

  /**
   * Array containing different error types on rejecting requests (promises)
   * @type {Array}
   */
  _errors = [];
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
   * Global method used from native to trigger events
   */
  var _fireEvent = function(type, data) {
    if (_events[type]) {
      _events[type].data = data;
      return document.dispatchEvent(_events[type]);
    }
    else {
      logger.error('Hybridge event not defined: ' + type);
    }
  };

  /**
   * Public returned Hybridge object
   * @type {Object}
   */
  var Hybridge = {
    isNative: _isNative,
    isEnabled: _isEnabled,
    send: _send,
    events: _events,
    errors: _errors
  };

  /**
   * Sets up the bridge in iOS environment
   */
  if (_isIos()) {
    logger.info('Fixing bridge for iOS, XHR method used');
    method = _sendXHR;
  }
  /**
   * Sets up the bridge in Android environment
   */
  else if (_isAndroid()) {
    logger.info('Fixing bridge for Android, prompt method used');
    method = _sendPrompt;
  }

  //HybridgeGlobal = {isReady:true, actions:['product']}; // for desktop debug

  /**
   * Since HybridgeGlobal is set from native just add the client methods
   */
  if (typeof HybridgeGlobal !== 'undefined') {
    HybridgeGlobal.fireEvent = _fireEvent;
  }

  return Hybridge;
});
