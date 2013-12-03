/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

package com.pdi.hybridge;

import java.io.IOException;

import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

@ServerEndpoint("/websocket")
public class WebSocketTest {

  @OnMessage
  public void onMessage(String message, Session session) 
    throws IOException, InterruptedException {

    // Print the client message for testing purposes
    System.out.println("Received: " + message);

    // Send the first message to the client
    session.getBasicRemote().sendText("This is the first server message");

    // Send 3 messages to the client every 5 seconds
    int sentMessages = 0;
    while(sentMessages < 3){
      Thread.sleep(5000);
      session.getBasicRemote().
        sendText("This is an intermediate server message. Count: " 
          + sentMessages);
      sentMessages++;
    }

    // Send a final message to the client
    session.getBasicRemote().sendText("This is the last server message");
  }

  @OnOpen
  public void onOpen() {
    System.out.println("Client connected");
  }

  @OnClose
  public void onClose() {
    System.out.println("Connection closed");
  }
}