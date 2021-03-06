//
//  SocketIOManager.swift
//  LT Driver
//
//  Created by Dmitry Onishchuk on 06.07.2021.
//  Copyright © 2021 Lubimoe Taxi. All rights reserved.
//

import Foundation
import SocketIO

protocol SocketIOObserver: AnyObject {
    func newMessage(message: Any)
}

protocol SocketIOObserverProtocol{
    func addObserver(_ subscriber: SocketIOObserver)
    func removeObserver(_ subscriber: SocketIOObserver)
}

let chatURL = "http://socketio-chat-h9jt.herokuapp.com/"

class SocketIOManager: SocketIOObserverProtocol {
    
    static let shared = SocketIOManager(socketURL: URL(string: chatURL)!)
    
    private let RECONNECTION_ATTEMPT = 10;
    private let RECONNECTION_DELAY = 5000;
    
    private var socket: SocketIOClient!
    private var manager: SocketManager!
    private lazy var subscribers = [SocketIOObserver]()
    
    private init(socketURL: URL) {
        let config: SocketIOClientConfiguration = [.log(false),
                                                   .forceNew(true),
                                                   .reconnects(true),
                                                   .reconnectAttempts(RECONNECTION_ATTEMPT),
                                                   .reconnectWait(RECONNECTION_DELAY),
                                                   .compress]
        
        self.manager = SocketManager(socketURL: socketURL, config: config)
        self.socket = manager.defaultSocket
        setupListeners()
        setup()
    }
    
    private func setup(){
        self.establishConnection()
    }
    
    // MARK: Observer Functions
    
    func addObserver(_ subscriber: SocketIOObserver){
        if isUniqSubscriber(subscriber: subscriber) {
            subscribers.append(subscriber)
            print("[SocketIO] Someone subscribed to observer. " + String(subscribers.count) + " subscribers")
        }else{
            print("[SocketIO] Someone didn't subscribed to observer. Is already subscriber")
        }
    }
    
    func removeObserver(_ subscriber: SocketIOObserver){
        if let index = subscribers.firstIndex(where: {$0 === subscriber}){
            subscribers.remove(at: index)
            print("[SocketIO] Someone unsubscribed from observer. " + String(subscribers.count) + " subscribers")
        }
    }
    
    private func isUniqSubscriber(subscriber: SocketIOObserver) -> Bool{
        for sub in  subscribers {
            if sub === subscriber{
                return false
            }
        }
        return true
    }
    
    // MARK: SocketIO Functions
    
    private func setupListeners() {
        
        socket.on(clientEvent: .connect) {[weak self] data, ack in
            self?.connected()
        }
        
        socket.on(clientEvent: .reconnect) {[weak self] data, ack in
            self?.reconnect()
        }
        
        socket.on(clientEvent: .reconnectAttempt) {[weak self] data, ack in
            self?.reconnectAttempt()
        }
        
        socket.on(clientEvent: .disconnect) {[weak self] data, ack in
            self?.disconnected()
        }
        
        socket.on(clientEvent: .statusChange) {[weak self] data, ack in
            print("[SocketIO] statusChanged: " + (self?.socket.status.description)!)
        }
        
        socket.on(clientEvent: .error) {[weak self] data, ack in
            print("[SocketIO] ERROR: ")
            if data.count > 0 {
                print(data)
            }
        }
        
        
        socket.on(SocketIOEvent.TYPING.rawValue) { (data: TypingResponse) in
            self.isTyping(data: data)
        }
        
        socket.on(SocketIOEvent.STOP_TYPING.rawValue) {[weak self] data, ack in
            if data.count > 0 {
                self?.stopTyping(data: data)
            }
        }
        
        socket.onAny({(event) in
            //print("[SocketIO] Got event: \(event.event), with items: \(event.items)")
        })
    }
    
    private func connected(){
        print("[SocketIO] Connected")
    }
    
    private func reconnect(){
        print("[SocketIO] Reconnect")
    }
    
    private func reconnectAttempt(){
        print("[SocketIO] Reconnect Attempt")
    }
    
    private func disconnected(){
        print("[SocketIO] Disconnected")
    }
    
    private func isTyping(data: TypingResponse){
        print(String(describing: self) + " " + #function)
        print(data)
        
        let me = MessageEvent(event: SocketIOEvent.TYPING, data: data, error: nil)
        notifyEvent(message: me)
    }
    
    private func stopTyping(data: [Any]){
        print("[SocketIO] " + #function)
        print(data)
        
        guard let json = data.first as? mJSON else { return }
        let me = MessageEvent(event: SocketIOEvent.STOP_TYPING, data: json, error: nil)
        notifyEvent(message: me)
    }
    
    private func notifyEvent(message: MessageEvent){
        print("[SocketIO] " + #function)
        subscribers.forEach{$0.newMessage(message: message)}
    }

    // MARK: Public Functions
    
    func establishConnection() {
        print("[SocketIO] " + #function)
        if (self.socket?.status == .disconnected || self.socket?.status == .notConnected ) {
            socket?.connect()
        }
        else {
            print("[SocketIO] already connected")
        }
    }
    
    func getStatus() -> SocketIOStatus? {
        guard let status = self.socket?.status else{ return nil }
        return status
    }
    
    func login(){
        print("[SocketIO]: " + #function)
        //sendEvent(event: SocketIOEvent.LOGIN, json: "TestUser")
        socket.emit(SocketIOEvent.LOGIN.rawValue, "TestUser")
    }
    
    func sendEvent(event:SocketIOEvent, json: mJSON){
        // print("sendEvent: " + "\"" + event.rawValue + "\"" + ". With JSON:")
        // print(json)
        
        print("[SocketIO]: sendEvent: " + "\"" + event.rawValue + "\"" + ". With JSON:")
        print(json)
        socket.emit(event.rawValue, json)
    }
    
}
