define([
  'jquery',
  'init-has',
  'tid'
], function ($, has, TID) {
  /**
   * Manage two ways calls between javascript browser environment and native (iOS & Android)
   * @class Hybridge
   */

  var uniqueId = 1;
  var responseCallbacks = {};
  var xhr = null;
  var method = null;

  var logger = TID.Logger.getLogger(TID.Logger.Facility.DEFAULT, 'Hybridge');

  function send (data) {
    if(has('ios_native') || has('android')) {
      logger.info('Hybridge.send()', data);
      return _service(data);
    }
    else {
      logger.warn('Hybridge: Attempting to use Hybridge on a non native environment');
      return $.Deferred().reject('No native environment').promise();
    }
  }

  function _service (data) {
    if (data.url) {
      window.location = data.url;
    }
    else if (window.HybridgeGlobal && HybridgeGlobal.isReady) {
      if (data.action) {
        return method(data);
      }
      else {
        logger.warn('Hybridge: wrong params.');
      }
    }
    else {
      logger.warn('Hybridge: No native implementation present, using location URL fallback');
    }
  }

  function _servicePrompt (data) {
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
        def.reject(e.message);
      }
    });
    return def.promise();
  }

  function _serviceXHR (data) {
    if (data.callback) {
      var callbackId = 'cb_' + (uniqueId++) + '_' + new Date().getTime();
      responseCallbacks[callbackId] = callback;
      data['callbackId'] = callbackId;
    }
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
          xhr.reject("HTTP error: " + xhr.status);
        }
      },
      error: function(xhr, text, textError) {
        logger.error('Error on bridge to native. Non native environment?');
      }
    });
    return xhr.promise();
  }

/*  var _handleMsgFromNative = function (msgJSON) {
    var msgJSON = msgJSON || JSON.stringify(mockData);
    setTimeout(function(){
      var msg = JSON.parse(msgJSON), responseCallback, msgHandler;
      if (msg.callbackId) {
        responseCallback = responseCallbacks[msg.callbackId];
        if (responseCallback) {
          responseCallback(msg);
          delete responseCallbacks[msg.callbackId];
        }
      }
    });
  }*/

  /**
   * Method required for backwards compatibility event creation (Android Webkit)
   */
  var _createEvent = function (name) {
    var ev = null;
    if(typeof CustomEvent != 'undefined') {
      ev = new CustomEvent(name);
    }
    else {
      ev = document.createEvent('Event');
      ev.initEvent(name, true, true);
    }
    return ev;
  };

  var events = [];
  events['HybridgeReady'] = _createEvent('HybridgeReady');
  events['hybridgeMessage'] = _createEvent('HybridgeMessage');
  events['HybridgePause'] = _createEvent('HybridgePause');
  events['HybridgeResume'] = _createEvent('HybridgeResume');

  var _fireEvent = function(type, data) {
    if (events[type]) {
      events[type].data = data;
      return document.dispatchEvent(events[type]);
    }
    else {
      logger.error('Hybridge event not defined: ' + type);
    }
  };

  var Hybridge = {
    send: send,
    events: events
   // ,_handleMsgFromNative: _handleMsgFromNative
  };

  // Fix platform
  if (has('ios_native')) {
    logger.info('Fixing bridge for iOS, XHR method used');
    method = _serviceXHR;
    /*
    window.deviceready = document.createEvent('Events');
    deviceready.initEvent('HybridgeReady');
    deviceready.bridge = Hybridge;
    document.dispatchEvent(deviceready);
    */
  }
  else if (has('android')) {
    logger.info('Fixing bridge for Android, prompt method used');
    method = _servicePrompt;
  }
HybridgeGlobal = {};
  if (typeof HybridgeGlobal !== 'undefined') {
    HybridgeGlobal.fireEvent = _fireEvent;
    //HybridgeGlobal.isReady = true; // for desktop debug
  }

  return Hybridge;
});
