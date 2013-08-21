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

  var logger = TID.Logger.getLogger(TID.Logger.Facility.DEFAULT, 'Hybridge');

  var mockData = {};

  var init = function (msgHandler) {
    logger.info('init Hybridge');
  }

  function send(data) {
    if(has('ios_native') || has('android')) {
      logger.info('Hybridge.send()', data);
      //return _service(data);
      return _serviceTmp(data);
    }
    else {
      logger.warn('Hybridge: Attempting to use bridge on a non native environment.');
    }
  }

  function _serviceTmp (data) {
    if (data.url) {
      window.location = data.url;
    }
    else if (HybridgeGlobal && HybridgeGlobal.isReady && data.action) {
      return _service(data);
    }
  }

  function _service (data) {
    if (data.callback) {
      var callbackId = 'cb_' + (uniqueId++) + '_' + new Date().getTime();
      responseCallbacks[callbackId] = callback;
      data['callbackId'] = callbackId;
    }
    var strJSON = JSON.stringify(data);
    if (xhr && xhr.readyState != 4) {
        xhr = null;
    }
    mockData['callbackId'] = callbackId;
    var action = data.action;
    var id = data.id;
    xhr = $.ajax({
      //url: '/js', // URL for testing
      url: 'http://hybridge/' + action +'/' + id + '/' + new Date().getTime(),
      type: 'HEAD',
      headers: { 'data': strJSON || '{}' },
      done: function() {alert('done');
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
      error: function() {
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
    init: init,
    send: send,
    events: events
   // ,_handleMsgFromNative: _handleMsgFromNative
  };

  // Fix platform
  if (has('ios')) {
    logger.info('Fixing bridge for iOS');

    /*
    window.deviceready = document.createEvent('Events');
    deviceready.initEvent('HybridgeReady');
    deviceready.bridge = Hybridge;
    document.dispatchEvent(deviceready);
    */
  }
  else if (has('android')) {
    logger.info('Fixing bridge for Android');
  }

  if (typeof HybridgeGlobal == 'undefined') {
    HybridgeGlobal = {};
  }

  HybridgeGlobal.fireEvent = _fireEvent;   

  return Hybridge;
});
