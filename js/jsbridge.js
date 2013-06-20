define([
  'jquery',
  'has'
], function ($, has) {
  /**
   * Manage two ways calls between javascript browser environment and native (iOS & Android)
   * @class JsBridge
   */

  var uniqueId = 1;
  var responseCallbacks = {};
  var xhr = null;

  var mockData = {};

  var init = function (msgHandler) {
    console.log('init JsBridge');
  }

  function send(data, responseCallback) {
    _doSend(data, responseCallback);
  }

  function _doSend (message, responseCallback) {
    if (responseCallback) {
      var callbackId = 'cb_' + (uniqueId++) + '_' + new Date().getTime()
      responseCallbacks[callbackId] = responseCallback
      message['callbackId'] = callbackId
    }
    var strJSON = JSON.stringify(message);
    if (xhr && xhr.readyState != 4) {
        xhr = null;
    }
    mockData['callbackId'] = callbackId;
    var action = 'state';
    var id = 666;
    xhr = $.ajax({
      url: '/js', // URL for testing
      //url: 'hybridge://' + action +'/' + id + '/' + new Date().getTime(),
      type: 'HEAD',
      beforeSend: function (xhr) {
        xhr.setRequestHeader('data', strJSON);
      },
      error: function () { console.error('error') }, 
      success: _handleMsgFromNative
    });
  }

  var _handleMsgFromNative = function (msgJSON) {
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
  }

  var JsBridge = {
    init: init,
    send: send,
    _handleMsgFromNative: _handleMsgFromNative
  }

  // Fix platform
  if (has('ios')) {
    console.log('Fixing bridge for iOS');

    var deviceready = document.createEvent('Events');
    deviceready.initEvent('JsBridgeReady');
    deviceready.bridge = JsBridge;
    document.dispatchEvent(deviceready);
  }
  else if (has('android')) {
    console.log('Fixing bridge for Android');
  }

  return JsBridge;
});
