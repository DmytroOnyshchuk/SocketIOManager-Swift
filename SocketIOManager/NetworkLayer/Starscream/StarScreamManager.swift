//
//  StarScreammanager.swift
//  SocketIOTest
//
//  Created by Dmitry Onishchuk on 02.07.2021.
//

import Foundation
import Starscream

let echo = "ws://echo.websocket.org"

class StarScreamManager: WebSocketDelegate{
    
    static let shared = StarScreamManager(socketURL: URL(string: echo)!)
    
    let socket: WebSocket!
    
    init(socketURL: URL) {
        var request = URLRequest(url: socketURL)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        
        
        socket.connect()
    }
    
    
    func websocketDidConnect(socket: WebSocketClient) {
        print(#function)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print(#function)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(#function)
        print(text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print(#function)
    }
    
    func sendMessage(msg: String){
        socket.write(string: msg)
    }
    
}
